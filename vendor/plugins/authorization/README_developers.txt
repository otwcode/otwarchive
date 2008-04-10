
INSTRUCTIONS FOR DEVELOPERS:

Pushing a read-only copy of the git repo master branch to the google code SVN repo.
--

Based on an article found at :
http://blog.nanorails.com/articles/2008/1/31/git-to-svn-read-only

Setup:

Clone a local copy of the git repo from GitHub:

'git clone git@github.com:DocSavage/rails-authorization-plugin.git'

cd rails-authorization-plugin

edit .git/config and add the following to the end:

--
[svn-remote "googlecode"]
  url = https://rails-authorization-plugin.googlecode.com/svn/trunk
  fetch = :refs/remotes/googlecode
--

run : 'git svn fetch'

run : 'git checkout -b local-svn googlecode'

run : 'git svn rebase'

run : 'git merge master'

run : 'git svn dcommit'


Now in the future as new changes are commit to master, do this to publish to GoogleCode:

$ git checkout local-svn
$ git merge master
$ git svn dcommit

And thats it!
