using System.Web.Mvc;

namespace HelloWorldApp.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.Message = "Hello World!";
            return View();
        }
    }
}
