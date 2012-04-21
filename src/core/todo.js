todo = {
    execute: function(argv, env, filesystem, ui) {
        var opt;

        while ((opt = getopt(argv, ':aef:hvwz')) != '') {
            switch (opt) {
               case 'a':
                   var name = ui.ask('What is your name? ');
                   ui.echo('Your name is: ' + name);
                   break;
               case 'e':
                   ui.echo('env:');
                   ui.echo(env);
                   break;
               case 'f':
                   ui.echo('f option found. Argument is: ' + optarg);
                   ui.echo(filesystem.load(optarg));
                   break;
               case 'h':
                   ui.echo('usage: ' + env.TODO_SH + ' [-f filename] [-g] [-v]');
                   return 0;
               case 'v':
                   ui.echo('argv: ' + argv);
                   // ui.echo('process.argv: ' + process.argv);
                   break;
               case 'w':
                   ui.echo('writing to file: todo.out');
                   ui.echo(filesystem.save('todo.out', 'CONTENT'));
                   break;

               case ':':
                   ui.echo('Error - Option needs a value: ' + optopt);
                   return 1;
               case '?':
                   ui.echo('Error - No such option: ' + optopt);
                   return 1;
               default:
                   ui.echo('Error - Option implemented yet: ' + optopt);
                   return 1;
             }
        }
        return 0;
    }
}
