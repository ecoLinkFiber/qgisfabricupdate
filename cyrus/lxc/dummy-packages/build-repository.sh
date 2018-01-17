#!/bin/bash

    #cd /srv/packages/local-"$1"

    # Generate the Packages file
    dpkg-scanpackages . /dev/null > Packages
    gzip --keep --force -9 Packages

    # Generate the Release file
    #cat conf/distributions > Release
cat > Release << EOF
Archive: archive
Component: component
Origin: Example
Label: Example
Architecture: all
EOF
    # The Date: field has the same format as the Debian package changelog entries,
    # that is, RFC 2822 with time zone +0000
    echo -e "Date: `LANG=C date -Ru`" >> Release
    # Release must contain MD5 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
    echo -e 'MD5Sum:' >> Release
    printf ' '$(md5sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
    printf '\n '$(md5sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release
    # Release must contain SHA256 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
    echo -e '\nSHA256:' >> Release
    printf ' '$(sha256sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
    printf '\n '$(sha256sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release

    # Clearsign the Release file (that is, sign it without encrypting it)
    #gpg --clearsign --digest-algo SHA512 --local-user $USER -o InRelease Release
    # Release.gpg only need for older apt versions
    # gpg -abs --digest-algo SHA512 --local-user $USER -o Release.gpg Release

    # Get apt to see the changes
    #sudo apt-get update
