## makeR

Makefile and tools for R packages

This is a git submodule we include in our R packages to have a Makefile and some tools for package building, testing and documentation generation. Including this as a submodule in other projects enables us to hold the code for this in one central place (i.e., here) without copy-paste horror. 

The submodule is always included under the path 'makeR' in the respective package repositories, e.g., look here:
https://github.com/berndbischl/BBmisc

### Installing the submodule

Execute this in a terminal:

```
curl http://krlmlr.github.io/makeR/install | sh
```

For installing with read-write access, use e.g.

```
curl http://krlmlr.github.io/makeR/install | sh -s krlmlr
```

where `krlmlr` is your GitHub user name.


### Initially cloning the submodule

If the 'makeR' directory is empty after you have cloned a package repository, simply do 

```
git submodule init
git submodule update
```

while in bash in the main, top-level directory of the respective package repo.

### Updating makeR

If we update the makeR tool chain, somebody has to update the submodule for the package repo once as well. 
IT IS VERY LIKELY THAT THIS PERSON IS ME OR MICHEL AND NOT YOU. YOU PROBABLY DO NOT HAVE TO DO ANYTHING. 
It works like this: 

```
git submodule init
git submodule update
cd makeR
git checkout master
git pull
cd ..
```

Theen add, commit and push the makeR directory. We can all agree that this sucks.

### More info

http://chrisjean.com/2009/04/20/git-submodules-adding-using-removing-and-updating/










