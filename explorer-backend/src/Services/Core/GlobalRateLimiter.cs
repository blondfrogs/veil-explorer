using System.Collections.Concurrent;

namespace ExplorerBackend.Services.Core;

public class GlobalRateLimiter
{
    private readonly ConcurrentDictionary<string, Queue<DateTime>> _requestTimestamps = new();
    private readonly SemaphoreSlim _semaphore = new(1, 1);

    /// <summary>
    /// Checks if a request is allowed based on global rate limiting
    /// </summary>
    /// <param name="key">The unique key for this rate limit (e.g., method name)</param>
    /// <param name="maxRequests">Maximum number of requests allowed</param>
    /// <param name="timeWindow">Time window in seconds</param>
    /// <returns>True if request is allowed, false if rate limit exceeded</returns>
    public async Task<bool> IsAllowedAsync(string key, int maxRequests, int timeWindow)
    {
        await _semaphore.WaitAsync();
        try
        {
            var now = DateTime.UtcNow;
            var windowStart = now.AddSeconds(-timeWindow);

            // Get or create the queue for this key
            var timestamps = _requestTimestamps.GetOrAdd(key, _ => new Queue<DateTime>());

            // Remove expired timestamps
            while (timestamps.Count > 0 && timestamps.Peek() < windowStart)
            {
                timestamps.Dequeue();
            }

            // Check if limit exceeded
            if (timestamps.Count >= maxRequests)
            {
                return false;
            }

            // Add current timestamp
            timestamps.Enqueue(now);
            return true;
        }
        finally
        {
            _semaphore.Release();
        }
    }

    /// <summary>
    /// Gets the number of requests made in the current window
    /// </summary>
    public int GetRequestCount(string key, int timeWindow)
    {
        if (!_requestTimestamps.TryGetValue(key, out var timestamps))
            return 0;

        var windowStart = DateTime.UtcNow.AddSeconds(-timeWindow);
        return timestamps.Count(t => t >= windowStart);
    }

    /// <summary>
    /// Gets the time until the rate limit resets
    /// </summary>
    public TimeSpan? GetTimeUntilReset(string key, int timeWindow)
    {
        if (!_requestTimestamps.TryGetValue(key, out var timestamps) || timestamps.Count == 0)
            return null;

        var oldestTimestamp = timestamps.Peek();
        var resetTime = oldestTimestamp.AddSeconds(timeWindow);
        var timeUntilReset = resetTime - DateTime.UtcNow;

        return timeUntilReset > TimeSpan.Zero ? timeUntilReset : TimeSpan.Zero;
    }
}
