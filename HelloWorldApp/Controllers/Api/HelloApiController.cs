using System.Web.Http;

namespace HelloWorldApp.Controllers.Api
{
    public class HelloApiController : ApiController
    {
        // GET api/hello
        public IHttpActionResult Get()
        {
            return Ok(new { message = "Hello World!", timestamp = System.DateTime.UtcNow });
        }

        // GET api/hello/{name}
        public IHttpActionResult Get(string id)
        {
            return Ok(new { message = "Hello, " + id + "!", timestamp = System.DateTime.UtcNow });
        }
    }
}
