﻿using System.Collections.Generic;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Logging;
using System.Linq;
using Microsoft.AspNet.Http;

namespace Kanban.Controllers
{
    public class TaskModel 
    {
        public int Id { get; set; }
        public string Description { get; set; } 
        
        public int ColumnId { get; set; }       
    }
    
    public class AddTaskResponse 
    {
        public int Id { get; set; }        
    }

    public class TaskProperties
    {
        public string Description { get; set; }
        public int ColumnId { get; set; }
    }
    
    [Route("api/task")]
    public class TasksController : Controller
    {
        private static System.Collections.Concurrent.ConcurrentDictionary<int, TaskProperties> tasks = 
            new System.Collections.Concurrent.ConcurrentDictionary<int, TaskProperties>() 
            {
                [1] = new TaskProperties() { Description = "First task", ColumnId = 1 },
                [2] = new TaskProperties() { Description = "SECOND TASK longer description", ColumnId = 2 },
            };
        private static volatile int nextId = 3;
            
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
                .Select(kvp => new TaskModel() 
                    { 
                        Id = kvp.Key,
                        Description = kvp.Value.Description,
                        ColumnId = kvp.Value.ColumnId 
                });
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var task = tasks
                .Where(x => x.Key == id)
                .Select(kvp => new TaskModel()
                {
                    Id = kvp.Key,
                    Description = kvp.Value.Description,
                    ColumnId = kvp.Value.ColumnId
                })
                .FirstOrDefault();

            if (task == null)
            {
                return new HttpNotFoundResult();
            }

            return new HttpOkObjectResult(task);
        }

        [HttpPost]
        public AddTaskResponse Post([FromBody]string description)
        {
            var taskId = nextId++;
            var newTaskProperties = new TaskProperties()
            {
                Description = description,
                ColumnId = 0
            };

            tasks.AddOrUpdate(taskId, _ => newTaskProperties, (k, p) => newTaskProperties);
            _logger.LogInformation($"POST: {description}");
            
            return new AddTaskResponse { Id = taskId };
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] TaskProperties properties)
        {
            _logger.LogInformation($"PUT: TASK ID = {id} {properties.Description} {properties.ColumnId}");
            tasks.AddOrUpdate(id, (x) => properties, (x, p) => properties);
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
            _logger.LogInformation($"DELETE: {id}");
            TaskProperties taskDescription;
            tasks.TryRemove(id, out taskDescription);
        }
    }
}
