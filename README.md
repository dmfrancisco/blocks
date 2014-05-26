logr.
-----

An app for people interested in gathering knowledge and making experiences for self-improvement.
Good for quantified-self researchers.

To initialize the project, run:

```bash
npm install -g ionic cordova gulp
npm install
ionic platform add ios
```

Now build the project by calling:

```bash
gulp
ionic build ios
```

Then open the Xcode project in the `platforms` folder and run the application.

Watch changes made to the source files by running the following command in the root directory:

```bash
gulp watch
```

To update the icons and splashscreen, move the files inside `res` to the appropriate directories.
