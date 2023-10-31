package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

var framework string = ""

func main() {
	if len(os.Args) <= 1 {
		print("file path is missing")
		os.Exit(1)
	}
	frameworkLocation := os.Args[1]
	println(frameworkLocation)
	framework = getName(frameworkLocation)
	fixer(frameworkLocation)
}

func fixer(frameworkLocation string) {

	libRegEx, e := regexp.Compile("^.+\\.(swiftinterface)$")
	if e != nil {
		log.Fatal(e)
	}

	e = filepath.Walk(frameworkLocation, func(path string, info os.FileInfo, err error) error {
		if err == nil && libRegEx.MatchString(info.Name()) {
			println(path)
			input, err := ioutil.ReadFile(path)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			output := bytes.Replace(input, []byte(framework+"."), []byte(""), -1)

			if err = ioutil.WriteFile(path, output, 0666); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

		}
		return nil
	})
	if e != nil {
		log.Fatal(e)
	}
}
func getName(file string) string {
	names := strings.Split(file, "/")
	name := strings.Replace(names[len(names)-1], ".xcframework", "", -1)
	return name
}
