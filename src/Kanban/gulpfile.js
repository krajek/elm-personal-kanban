/// <binding BeforeBuild='elm' />
/*
This file in the main entry point for defining Gulp tasks and using Gulp plugins.
Click here to learn more. http://go.microsoft.com/fwlink/?LinkId=518007
*/

var gulp = require('gulp');
var elm = require('gulp-elm');

var webroot = './wwwroot/';
var jsDest = webroot + 'js';

gulp.task('elm', function () {
    return gulp.src('Scripts/elm-src/Main.elm')
      .pipe(elm())
      .pipe(gulp.dest(jsDest));
});

gulp.task('default', function () {
    // place code for your default task here
});