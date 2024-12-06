set shell := ["bash", "-c"]

default:
    @just --list

build:
    odin build .

debug:
    odin run . -debug -define:DEBUG_MODE=true -define:SHOW_FPS=true

build-release:
    odin build . -o:speed

run:
    odin run . -define:SHOW_FPS=true
