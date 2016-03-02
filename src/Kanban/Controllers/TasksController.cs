using System.Collections.Generic;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Logging;
namespace Kanban.Controllers
{
    [Route("api/task")]
    public class TasksController : Controller
    {
        private static System.Collections.Concurrent.BlockingCollection<string> tasks = 
            new System.Collections.Concurrent.BlockingCollection<string>() 
            {
                "FIRST TASK",
                "SECOND TASK longer name"
            };
            
        private readonly ILogger<TasksController> _logger;
        public TasksController(ILogger<TasksController> logger) 
        {
            _logger = logger;
        }
        
        // GET: api/values
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return tasks.ToArray();
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody]string description)
        {
            tasks.Add(description);
            _logger.LogInformation($"POST: {description}");
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
