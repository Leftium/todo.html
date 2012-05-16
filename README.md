# NOTE: This is an alpha pre-release!
##### This document describes the Todo.html vision. Although fully functional, some features may not be implemented yet...
###### For example, the individual html, css, and javascript files have not been build into a single file yet. Please download all the files to try it out. (You can manually assemble the files, if you wish...)

## What is Todo.html?

Todo.html is text-based task management streamlined to be even simpler and more portable. It is a local, cross-platform, single-page-application for viewing, searching, and modifying a text-based todo list. If you're new to the todo.txt concept, start [here](http://www.todotxt.com/).


## Isn't Todo.txt already simple and portable?

Todo.txt veterans might ask, "How could a plain text file be made any simpler or more portable?" Well, the management tools surrounding this todo.txt file are not so simple and portable. For instance, your favorite text editor may not be available on certain computers. Anyways, most people prefer to use specialized tools like todo.sh for their specialized search and editing features. The todo.sh script requires a Unix-like system, which only a handful of systems (Mac/Linux) support out of the box. Windows systems need to install a emulation layer called Cygwin (whose hefty install is *not* simple). Even assuming constant access to a Unix-like system, the minimal configuration still needs at least three files: todo.txt, todo.sh, and todo.cfg.


## How does Todo.html improve over Todo.txt?

Enter Todo.html: like Todo.txt, it's a plain text file that stores your tasks. You can modify it in any text editor. In addition, open the same todo.html file in a web browser to find a familiar, convenient interactive interface. Those handy, specialized Todo.txt-CLI editing and search commands are built right in to the actual todo.html file--no other files needed! Effectively, the todo.sh and todo.cfg files have been folded into the todo.txt file. As long as you have your todo.html file, installation is simply a matter of copying this single file to another computer, any computer! The todo.html file is still easily editable/viewable in a regular text editor because the extra data is appended to the very end of the file as a single line (disable word wrap for best effect).


## Todo.html extra features

In addition to the familiar todo.sh-compatible command line interface, Todo.html introduces some new features:

- Google 'instant search'-style list-as-you-type
- Automatic hyper-linking of web/email addresses in task text
- Relative dates
- Graphical date picker
- Graphical task visualization
- Pinned projects/contexts that are automatically inserted until unpinned
- GUI interface elements

## Compatibility with Todo.txt

Todo.html supports a hybrid mode where the todo.txt and todo.cfg files are externally stored. Used this way, todo.html is a near drop-in replacement for todo.sh. In fact, the JavaScript core of Todo.html is accessible from the command line via a simple bash script wrapper (also named todo.sh). There is an analogous todo.bat wrapper for Windows systems. Actually, files/tasks can even be transferred into and out of todo.html's internal filesystem.

Todo.html's major limitation is lack of true integration with the OS. Todo.html cannot run shell-based Todo.txt-CLI plugin. If some plugin is absolutely required, another todo.html.sh wrapper is available. This wrapper wraps the original todo.txt-cli script by stripping the extra html before sending the input file, and re-appending the html to the output files. Also, Todo.html cannot list directories or access environment variables.


# How to get started:

1. Save todo.html as a local file on your computer
2. Make sure your todo.cfg file is located in the same directory as todo.html
3. Open todo.html in your web browser.
4. Enter commands just like you would for todo.sh on the command line