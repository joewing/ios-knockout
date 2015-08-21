

all: KOLevelGen

run: KOLevelGen
	java KOLevelGen

KOLevelGen:
	javac -Xlint:deprecation *.java

jar: KOLevelGen
	jar -cvfm ../KOLevelGen.jar META-INF/MANIFEST.MF  *.class images/*

clean:
	rm *.class

