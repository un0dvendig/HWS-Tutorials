## TO-DO:
- [X] Fix deleting the last row from a particular section. (Experiment with using deleteSections() rather than deleteRows())
- [X] **Tricky** Use the "url" attribute of Commit in the detail view controller to show the GitHub page in a WKWebView rather than just a label.
- [ ] *Fun* Create a new Xcode project using the Master-Detail Application template, but enable the Core Data checkbox.
- [ ] **_Taxing_** Rewrite the getNewestCommitDate() method so that it uses UserDefaults rather than a fetch request in order to fix the bug in the current implementation. (If users delete the most recent commit message, we also lose our most recent date) 
- [X] `Mayhem` Complete the showAuthorCommits() method in the detail view controller. This should show a new table view controller listing other commits by the same author. (Try going to the Author entity, choosing its "commits" relationship, then checking the "Ordered" box and recreating the NSManagedObject subclass. Don't forget to remove the optionality from the properties that get generated)
