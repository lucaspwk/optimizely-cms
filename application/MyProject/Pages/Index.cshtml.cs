using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace MyProject.Pages;

public class IndexModel : PageModel
{
    public string PodIpAddress { get; set; }

    private readonly ILogger<IndexModel> _logger;

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public void OnGet()
    {
        // Retrieve the pod IP address from the environment variable
        PodIpAddress = Environment.GetEnvironmentVariable("POD_IP") ?? "Pod IP not found";
    }
}
