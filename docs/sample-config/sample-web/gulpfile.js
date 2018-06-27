const
  gulp = require('gulp'),
  include = require('gulp-include'),
  gulpReplace = require('gulp-replace'),
  fs = require('fs');
  
const PKG = JSON.parse(fs.readFileSync('./package.json'))

gulp.task(
    'processHtml',
    function() {
        return gulp.src(['./src/*.html'], {base: './src'})
            .pipe(include())
            .pipe(gulpReplace(/{{VERSION}}/g, PKG.version))
            .pipe(gulp.dest('dist'));
    }
);

gulp.task('default', ['processHtml']);