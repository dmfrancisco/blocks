var gulp = require('gulp');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');

var paths = {
  coffee: [
    './coffee/utils.coffee',
    './coffee/config.coffee',
    './coffee/app.coffee',
    './coffee/models.coffee',
    './coffee/controllers.coffee',
    './coffee/directives.coffee'
  ],
  sass: [
    './scss/**/*.scss'
  ]
};

// Minify and copy all SCSS files (including vendor stylesheets)
gulp.task('sass', function() {
  return gulp.src('./scss/app.scss')
    .pipe(sass())
    .pipe(minifyCss({
      keepSpecialComments: 0
    }))
    .pipe(gulp.dest('./www/css/'));
});

// Minify and copy all CoffeeScript (except vendor scripts)
gulp.task('coffee', function() {
  return gulp.src(paths.coffee)
    .pipe(coffee())
    .pipe(uglify({
      // Required for the Angular.js named variables
      mangle: false
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./www/js/'));
});

// Rerun the tasks when a file changes
gulp.task('watch', function() {
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.coffee, ['coffee']);
});

// The default task (called when you run `gulp` from cli)
gulp.task('default', ['sass', 'coffee']);
