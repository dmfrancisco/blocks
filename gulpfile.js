var gulp = require('gulp');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
var angularTemplates = require('gulp-angular-templatecache');

var paths = {
  assets: [
    './source/fonts/**/*',
    './source/sounds/**/*',
    './source/js/vendor/**/*',
    './source/index.html'
  ],
  sass: [
    './source/css/**/*.scss'
  ],
  coffee: [
    './source/js/**/*.coffee'
  ],
  templates: [
    './source/templates/**/*.html'
  ]
}

// Copy static files to the www folder
gulp.task('assets', function () {
  return gulp.src(paths.assets, {
      base: './source/'
    })
    .pipe(gulp.dest('./www'));
});

// Minify and copy all SCSS files (including vendor stylesheets)
gulp.task('sass', function() {
  return gulp.src("./source/css/app.scss")
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

gulp.task('templates', function () {
  return gulp.src(paths.templates)
    .pipe(angularTemplates({
      filename: "templates.js",
      module: "logr"
    }))
    .pipe(gulp.dest('./www/'));
});

// Rerun the tasks when a file changes
gulp.task('watch', ['default'], function() {
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.coffee, ['coffee']);
  gulp.watch(paths.templates, ['templates']);
});

// The default task (called when you run `gulp` from cli)
gulp.task('default', ['assets', 'sass', 'coffee', 'templates']);
