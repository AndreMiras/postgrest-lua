# How to release

This is documenting the release process.

We're also using [semantic versioning](https://semver.org/) where `major.minor.patch` should be set accordingly.

```sh
VERSION=major.minor.patch
FULL_VERSION=$VERSION-1
ROCKSPEC=rockspecs/postgrest-$FULL_VERSION.rockspec
```

## Update package.json and tag

Create a new rockspec file and update it to match the new release version.

```sh
cp postgrest-dev-1.rockspec $ROCKSPEC
sed 's/version = "dev-1"/version = "'$FULL_VERSION'"/' --in-place $ROCKSPEC
sed 's/branch = "main"/tag = "'$VERSION'"/' --in-place $ROCKSPEC
```

Then commit and tag:

```sh
git add $ROCKSPEC
git commit -a -m ":bookmark: $VERSION"
git tag -a $VERSION -m ":bookmark: $VERSION"
```

Push everything including tags:

```sh
git push
git push origin $VERSION
```

This will publish automatically to LuaRocks.
