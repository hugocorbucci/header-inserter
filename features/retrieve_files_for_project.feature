Feature: List all source files of a project
	In order to control my source code
	Maintainers should be able to
	easily find out each source file in their project

	Scenario: Source files of a non-existing project
		Given a non-existing project
		When I list "java" files
		Then I should get nothing

	Scenario: Source files of an empty project
		Given an empty project
		When I list "java" files
		Then I should get nothing

	Scenario: Source files on root of a project
		Given a non-structured project
		When I list "java" files
		Then I should get ["Main.java", "MainTest.java"]

	Scenario: Source files nested in a structured project
		Given a structured project
		When I list "java" files
		Then I should get ["src/my/project/Main.java", "src/my/project/internal/Logic.java", "test/my/project/internal/LogicTest.java"]