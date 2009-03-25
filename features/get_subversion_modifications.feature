Feature: Retrieve the history of a file from subversion
	In order to present the full data of a file
	Files should allow to
	retrieve modifications made to them over time through the subversion repository
	
	Scenario: History of a non shared file
		Given a file not version controlled
		When I retrieve its history
		Then I should receive an empty history

	Scenario: History of a one version shared file
		Given a file recently under version control
		When I retrieve its history
		Then I should receive a history with modifications:
		| revision | author        | date                | log                                      |
		| 1458     | hugo.corbucci | 2009-03-23 12:00:00 | Test file for the header-insert project. |

	Scenario: History of an old multi-version shared file
		Given a file under version control for some time
		When I retrieve its history
		Then I should receive a history with modifications:
		| revision | author        | date                | log                                      |
		| 1458     | hugo.corbucci | 2009-03-23 12:00:00 | Test file for the header-insert project. |
		| 1459     | hugo.corbucci | 2009-03-23 13:00:00 | Changing it.                             |
		| 1460     | hugo.corbucci | 2009-03-23 14:00:00 | Changing it again.                       |
		| 1461     | hugo.corbucci | 2009-03-23 15:00:00 | Last change.                             |