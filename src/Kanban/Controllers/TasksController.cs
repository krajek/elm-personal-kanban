using System.Collections.Generic;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Logging;
using System.Linq;

namespace Kanban.Controllers
{
    public class TaskModel 
    {
        public int Id { get; set; }
        public string Description { get; set; }        
    }
    
    [Route("api/task")]
    public class TasksController : Controller
    {
        private static System.Collections.Concurrent.ConcurrentDictionary<int, string> tasks = 
            new System.Collections.Concurrent.ConcurrentDictionary<int, string>() 
            {
                [1] = "First task",
                [2] = "SECOND TASK longer name"
            };
        private volatile int nextId = 3;
            
        private readonly ILogger<TasksController> _logger;
        public TasksController(ILogger<TasksController> logger) 
        {
            _logger = logger;
        }
        
        // GET: api/values
        [HttpGet]
        public IEnumerable<TaskModel> Get()
        {
            return tasks
                .ToArray()
                .Select(kvp => new TaskModel() { Id = kvp.Key, Description = kvp.Value });
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
            tasks.AddOrUpdate(nextId++, _ => description, (k, p) => description);
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
            _logger.LogInformation($"DELETE: {id}");
            string description;
            tasks.TryRemove(id, out description);
        }
    }
}
