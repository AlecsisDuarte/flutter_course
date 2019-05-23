# flutter_course
Flutter application created along the [Udemy course](https://www.udemy.com/share/1013o4BUIfeVtbTH4=/) I was following

## Getting started
In order to get the application up and running you will have to clone the repository:
```bash
git clone https://github.com/AlecsisDuarte/flutter_course.git

```
And then edit the configuration file at `flutter_course/assets/config.json`
adding your **Geocoding** and  **Authentication** API KEY both created at the [Google Developers Console](https://console.developers.google.com/) or you could use the same key for both.

You also have to create your Firebase project as shown in [here](https://firebase.google.com/docs/flutter/setup), paste the JSON file at `flutter_course/functions/<your firebase filename>.json`, enable the project storage, functions and update all the firebase information at the `config.json`.

Once you have all the information and files needed you will have to publish your functions using this command:
```bash
firebase deploy
```
You will need to install the [firebase](https://firebase.google.com/docs/functions/get-started#set-up-node.js-and-the-firebase-cli) command through [Node Package Manager (NPM)](https://www.npmjs.com/get-npm)


## Notes
* I haven't tested the iOS part of the application (Because I don't have a Mac :unamused: )
* This application was made just as a test/practice of the udemy course
* Here you can find mor information about firebase [functions](https://firebase.google.com/docs/functions/get-started) and [storage](https://firebase.google.com/docs/storage)
* Currently in order to deploy the firebase functions npm makes a copy of the `config.json` file using the unix command `cp` so it won't work on Windows, you would have to change the command in the `firebase.json` from `cp` to `copy`
* Icon made by [Freepik](https://www.freepik.com/) from [www.flaticon.com](www.flaticon.com)