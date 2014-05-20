logr.
-----

An app for people interested in gathering knowledge and making experiences for self-improvement.
Good for quantified-self researchers.

To initialize the project, run:

```bash
npm install -g ionic cordova
gem install sass
ionic platform add ios
```

Now build the project by calling:

```bash
ionic build ios
```

Then open the Xcode project in the `platforms` folder and run the application.

Watch changes made to the scss files by running the following watcher in the root directory:

```bash
sass --watch scss:www/css
```

To update the icons and splashscreen, move the files inside `res` to the appropriate directories.
