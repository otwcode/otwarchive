[![Build Status](https://travis-ci.org/otwcode/otwarchive.png)](https://travis-ci.org/otwcode/otwarchive) 

## About OTW-Archive

The OTW-Archive software is an open-source web application intended for hosting archives
of fanworks, including fanfic, fanart, and fan vids. Its development is sponsored by
the Organization for Transformative Works (http://transformativeworks.org), a nonprofit
organization by and for fans.

The OTW-Archive software is still in development and has not yet been released, but you
can see it in action on the Archive of Our Own (http://archiveofourown.org, aka AO3), a
multifandom archive also run by the OTW.

Our ultimate goal is to release OTW-Archive in a form that can be installed and used by
any fan archivist who wants to create her own archive. You can get more information about
our broad development plan at the OTW-Archive Roadmap:
http://transformativeworks.org/projects/archive.

Volunteers are always welcome both for coding and testing! Please contact us at:
http://transformativeworks.org/contact/volunteers%20and%20recruiting for full details, or
browse the Github pages (https://github.com/otwcode/otwarchive/wiki).

## Description of Contents

OTW-Archive is built using the Ruby on Rails framework, and uses the standard structure of a
Rails application. A few specific details are described here:

app
  Most of the code specific to this application lives under the app/ directory, organized
  into models (which represent the underlying objects in the database), views (which are the
  front end of the application), and controllers (which provide the glue).

  Works in the archive (eg, individual fanfic stories) are represented by the files:
    models/work.rb, controllers/works_controller.rb, and views/works.

  Users in the archive are represented by the files:
    models/user.rb, controllers/users_controller.rb, and views/users.

  Most metadata in the archive (fandoms, characters, etc) is represented as tags:
    models/tag.rb, controllers/tags_controller.rb, views/tags

public
  You can find the stylesheets, javascript, help files, and images used in this application
  under the public/ directory.

db
  The overall archive database layout can be found in the file schema.rb.

