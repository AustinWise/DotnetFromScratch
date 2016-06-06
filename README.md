# Dotnet From Scratch

I want to build a copy of the [.NET CLI](https://github.com/dotnet/cli) that
consists of only pieces I've built. This is not entirly straightforward as the
different projects that make up the .NET CLI resolve their dependancies on each
other through Nuget packages and Azure blob storage. If you build a repo in
isolation, you will be using Microsoft's pre-built packages.

This repo is my attempt to document how to build as much of the runtime
components of .NET Core (coreclr, corefx, and core-setup).

# Why bother

I was originally looking what would be involved in getting the .NET CLI on other
operating systems like FreeBSD. I discovered that the build process assumes you
have already ported .NET to the platform you are trying to build on! So I
thought I would first see what it takes to build .NET "from scratch" on an
already supported platform. Hopefully by identify better understanding the build
process

## Note to self

Might be able to just create a Microsoft.NETCore.App and reference it from a
project using an existing CLI. That should cover most of the runtime components.
