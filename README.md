# Fat
FAT -  make a self-extracting tar

There are few options:
* `-h` to show an help
* `-t` to specify a format, possible options are: bz2, gz, and xz, as *default* it use xz
* `-f` you *must* specify with this option which file or folder you want compress, can take only an argument

An example:
``` bash
FILENAME=test_$$
touch $FILENAME
./fat.sh -f $FILENAME -tgz && rm $FILENAME
./$FILENAME.fat
```

###### Copyright © 2017, [Manu-sh](https://github.com/Manu-sh), s3gmentationfault@gmail.com. Released under the [GPL3 license](LICENSE).
