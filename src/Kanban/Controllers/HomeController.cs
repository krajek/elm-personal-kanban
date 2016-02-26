using Microsoft.AspNet.Mvc;

namespace Kanban.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
