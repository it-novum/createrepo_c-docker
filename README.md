# createrepo_c-docker
Docker container to run createrepo_c to create RPM repositories with support for weak dependencies

## Build Docker Image 
```
docker build . -t openitcockpit/createrepo_c
```

## Use
```
docker run --rm -v /path/to/local/repo:/rpm openitcockpit/createrepo_c
```

## Why?
[That's why](https://github.com/jordansissel/fpm/issues/1457#issuecomment-945150958)


It is worth mentioning that if you want to use weak dependencies with an RPM repository you **HAVE TO USE** https://github.com/rpm-software-management/createrepo_c to create the repository. **Otherwise weak dependencies will not work.** 

Thanks to @gkralik I was able to build an rpm which recommends another rpm via fpm using `--rpm-tag "Recommends: pkg-b"`


```
[root@localhost ~]# LANG=c dnf install pkg-a
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 0:00:33 ago on Sun Oct 17 17:51:08 2021.
Dependencies resolved.
======================================================================================================
 Package          Architecture      Version               Repository                             Size
======================================================================================================
Installing:
 pkg-a            x86_64            1.0.5-1               foo.lan_rpm_            6.0 k
Installing weak dependencies:
 pkg-b            x86_64            1.0.5-1               foo.lan_rpm_            5.9 k

Transaction Summary
======================================================================================================
Install  2 Packages

Total download size: 12 k
Installed size: 51
Is this ok [y/N]:
```

You can use `rpm` to check if the packges got add to recommends and requires:
```
[17:57]root@build~# rpm -qp /tmp/pkg-a_1.0.5.x86_64.rpm --recommends --requires
pkg-b
basesystem
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
```

You can also query the --recommends from the repo:
```
[root@localhost ~]# LANG=c dnf repoquery --recommends pkg-a
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 0:07:19 ago on Sun Oct 17 17:51:08 2021.
pkg-b
```
If you get an empty list at this point, than the RPM repository was most likely created using the old python createrepo command instead of createrepo_c.

This took me a couple of hours to figure out.

Full fpm commands (Just for reference)
```
fpm --verbose --debug-workspace -s tar -t rpm -n pkg-a -p /tmp/pkg-a_1.0.5.x86_64.rpm -v 1.0.5 --license GPLv3 --maintainer 'a' --description "pkg a" --architecture x86_64 --depends basesystem --rpm-tag "Recommends: pkg-b" /root/pkg-a.tar.gz


fpm --verbose -s tar -t rpm -n pkg-b -p /tmp/pkg-b_1.0.5.x86_64.rpm -v 1.0.5 --license GPLv3 --maintainer 'b' --description "pkg b" --architecture x86_64 --depends basesystem  /root/pkg-b.tar.gz
```
