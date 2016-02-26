var gulp = require('gulp');
var elm  = require('gulp-elm');
 
gulp.task('elm', function(){
  return gulp.src('elm-src/Main.elm')
    .pipe(elm())	
    .pipe(gulp.dest('.'));
});

gulp.task('watch', function() {
    gulp.watch('*.elm', ['elm']);   
});

// Default Task
gulp.task('default', ['elm']);