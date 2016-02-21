var gulp = require('gulp');
var elm  = require('gulp-elm');
 
gulp.task('elm-init', elm.init);
 
gulp.task('elm', ['elm-init'], function(){
  return gulp.src('Main.elm')
    .pipe(elm())	
    .pipe(gulp.dest('.'));
});

gulp.task('watch', function() {
    gulp.watch('*.elm', ['elm']);   
});

// Default Task
gulp.task('default', ['elm', 'watch']);