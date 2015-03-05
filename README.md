EpiDumper
===================
A command line tool for multiple downloads using EpiQuest admin tool web application.

**Requirements**

 - Node 0.10 [download](http://nodejs.org/download/)
 - npm 2.6.0 (included from node.js download)
 - python 2.7.9 [download for 64bit](https://www.python.org/ftp/python/2.7.9/python-2.7.9.amd64.msi), [download for 32bit](https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi). Make sure to check 'Add python.exe to Path' when 'Customizing Python 2.7.9' in install.

(A good [resource](http://blog.teamtreehouse.com/install-node-js-npm-windows) describen node/npm installation for windows)

**Install**

From *Start* menu, type *cmd* to startup **command prompt**.
Go to the folder where you saved the file *epidumper-x.y.z.tgz*. 
Then enter
```
npm install -g epidumper-x.y.z.tgz
```
The `-g` flag address to install the program globally.

**Usage**

`epidumper` will display the proper usage for the program, which is basically 

```epidumper -b <batch-file>` or `epidumper --batch <batch-file>``` 

**JSON dumps configuration file**

Next is an example of a configuration file, which can be used as a template:
```json
{
  db: {
    "host": "localhost",
    "name": "appform",
    "user": "gcomesana",
    "pwd": "appform"
  },

  server: {
    "host": "localhost",
    "port": 8080,
    "app": "admtool",
    "servicePath": "datadump"
    user: 'mmarquez',
    pass: 'mmarquez'
    authPath: '/jsp/j_security_check'
  },

  dumps: [{
    "prj": "ISBlaC",
    questionnaire: "Aliquots_SP_New",
    group: "spain",
    section: 3,
    repd: false,
    out: ""
  }, {
    "prj": "PanGen-Eu",
    questionnaire: "QES_Spain",
    group: "spain",
    section: 3,
    repd: 1,
    out: ""
  }, {
    "prj": "PanGen-Eu",
    questionnaire: "QES_Español",
    group: "Hospital del Mar",
    section: 3,
    repd: false,
    out: ""
  }]
}
```
The file is a "*dirty-json*" file, which means it doesn't have to fit the JSON strict requirements about double quotes and commas.

**db** section holds the parameters for connecting to database:

- *host* is the database server host (default: *localhost*)
- *port* number of the database server port (default: 5432)
- *name* is the database name (default: *appform*)
- *user* is the database user
- *pwd* is the database password

**server** section holds application and application server parameters:

- *host* is the application server name or IP address (default: localhost)
- *port* is the port number where the application is listening (default: 8080)
- *app* is the name of the application (default: admtool)
- *servicePath* this is the path after the application name to access to the download service
- *user* this is the username which would log in the web application to make a download
- *pass* the password for the above user
- *authPath* this is the authorization path for the application, necessary to authentify user and his/her password

**dumps** section is where you define which data you want to retrieve. This is a list of dump parameters, which are:

- *prj* the name of the project
- *questionnaire* the name of the questionnaire to retrieve data
- *group* the name of the group the data want to be retrived for
- *section* the order of the section in the questionnaire (starts at 1)
- *repd* if the dump is one user by row (0 or false) or one block by row (1 or true)
- *output* not used