using System.Collections.Generic;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Logging;
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
        private static System.Collections.Concurrent.BlockingCollection<TaskModel> tasks = 
            new System.Collections.Concurrent.BlockingCollection<TaskModel>() 
            {
                new TaskModel() { Id = 1, Description = "First task" },
                new TaskModel() { Id = 2, Description = "SECOND TASK longer name" }
            };
            
        private readonly ILogger<TasksController> _logger;
        public TasksController(ILogger<TasksController> logger) 
        {
            _logger = logger;
        }
        
        // GET: api/values
        [HttpGet]
        public IEnumerable<TaskModel> Get()
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
            tasks.Add(new TaskModel() { Id = 3, Description = description });
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
