using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using ExplorerBackend.Models.Node;
using ExplorerBackend.Models.Node.Response;
using ExplorerBackend.Configs;
using ExplorerBackend.Services.Caching;
using ExplorerBackend.Services.Core;
using Microsoft.AspNetCore.Cors;
using ExplorerBackend.Core;

namespace ExplorerBackend.Controllers;

[ApiController]
[EnableCors(CORSPolicies.NodeProxyPolicy)]
[Route("/")]
public class NodeProxyController : ControllerBase
{
    private readonly string _invalidOperation;
    private readonly string _rateLimitExceeded;
    private readonly static List<string> _emptyList = [];
    private readonly IOptions<ServerConfig> _serverConfig;
    private readonly IOptions<ExplorerConfig> _explorerConfig;
    private readonly NodeRequester _nodeRequester;
    private readonly ChaininfoSingleton _chainInfoSingleton;
    private readonly GlobalRateLimiter _rateLimiter;
    private readonly ILogger<NodeProxyController> _logger;

    public NodeProxyController(IOptions<ServerConfig> serverConfig, IOptions<ExplorerConfig> explorerConfig, NodeRequester nodeRequester,
        ChaininfoSingleton chainInfoSingleton, GlobalRateLimiter rateLimiter, ILogger<NodeProxyController> logger)
    {
        _explorerConfig = explorerConfig;
        _serverConfig = serverConfig;
        _nodeRequester = nodeRequester;
        _chainInfoSingleton = chainInfoSingleton;
        _rateLimiter = rateLimiter;
        _logger = logger;
        _invalidOperation = JsonSerializer.Serialize(new GenericResult
        {
            Result = null,
            Id = null,
            Error = new()
            {
                Code = -2,
                Message = "Forbidden by safe mode or invalid method name" // RPC_FORBIDDEN_BY_SAFE_MODE
            }
        });
        _rateLimitExceeded = JsonSerializer.Serialize(new GenericResult
        {
            Result = null,
            Id = null,
            Error = new()
            {
                Code = -4,
                Message = "Rate limit exceeded. This method is limited to 10 calls per 10 minutes globally. Please try again later." // RPC_RATE_LIMITED
            }
        });
    }

    [HttpGet]
    public IActionResult Get()
    {
        if (_serverConfig.Value.Swagger?.RedirectFromHomepage ?? false)
            return Redirect(_serverConfig.Value.Swagger?.RoutePrefix ?? "");

        return Ok();
    }

    [HttpPost]
    public async Task<IActionResult> Post(JsonRPCRequest model, CancellationToken cancellationToken)
    {
        // verify method (and parameters?)
        if (!_explorerConfig.Value.NodeProxyAllowedMethods?.Contains(model.Method ?? "") ?? false)
            return Content(_invalidOperation, "application/json");

        // Rate limit for importlightwalletaddress (configurable via .env)
        if ((model.Method ?? "") == "importlightwalletaddress")
        {
            var rateLimitConfig = _explorerConfig.Value.ImportLightWalletRateLimit ?? new() { MaxCalls = 10, WindowSeconds = 600 };
            var maxCalls = rateLimitConfig.MaxCalls;
            var windowSeconds = rateLimitConfig.WindowSeconds;

            var isAllowed = await _rateLimiter.IsAllowedAsync("importlightwalletaddress", maxCalls, windowSeconds);

            if (!isAllowed)
            {
                var timeUntilReset = _rateLimiter.GetTimeUntilReset("importlightwalletaddress", windowSeconds);
                var currentCount = _rateLimiter.GetRequestCount("importlightwalletaddress", windowSeconds);

                _logger.LogWarning(
                    "Rate limit exceeded for importlightwalletaddress. Current: {CurrentCount}/{MaxCalls}, Reset in: {ResetTime}",
                    currentCount, maxCalls, timeUntilReset);

                return Content(_rateLimitExceeded, "application/json");
            }

            _logger.LogInformation("importlightwalletaddress called. Current count: {Count}/{Max}",
                _rateLimiter.GetRequestCount("importlightwalletaddress", windowSeconds), maxCalls);
        }

        if ((model.Method ?? "") == "getblockchaininfo")
        {
            var res1 = new GetBlockchainInfo
            {
                Id = model.Id,
                Result = _chainInfoSingleton.CurrentChainInfo
            };
            return Ok(res1);
        }

        if ((model.Method ?? "") == "getrawmempool")
        {
            var res1 = new GetRawMempool
            {
                Id = model.Id,
                Result = _chainInfoSingleton.UnconfirmedTxs?.Select(a => a.txid ?? "").ToList() ?? _emptyList
            };
            return Ok(res1);
        }


        var res = await _nodeRequester.NodeRequest(model.Method, model.Params, _explorerConfig.Value.UseHardRequestThrottleProxy, cancellationToken);
        return Content(res, "application/json");
    }
}