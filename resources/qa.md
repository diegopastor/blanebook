# QA Checklist — Library Management System UI

## Authentication and Authorization

- [ ] **1. Member registration succeeds with valid data**  
  Verify a new user can sign up from the UI with all required fields, is created successfully, and lands on the expected post-registration screen.

- [ ] **2. Registration fails with invalid or incomplete data**  
  Verify missing required fields, invalid email/password formats, duplicate accounts, or mismatched passwords show clear validation errors and prevent account creation.

- [ ] **3. User login succeeds with valid credentials**  
  Verify both Librarian and Member users can log in and are redirected to the correct dashboard.

- [ ] **4. User login fails with invalid credentials**  
  Verify incorrect email/password shows an error and does not create a session.

- [ ] **5. User logout works correctly**  
  Verify clicking logout ends the session and protected pages are no longer accessible without logging back in.

- [ ] **6. Unauthenticated users cannot access protected pages**  
  Try to open dashboards, books pages, borrow pages, or admin actions directly by URL and confirm redirect to login or an access-denied experience.

- [ ] **7. Librarian sees Librarian-specific navigation and actions**  
  Verify Librarian users can see controls for adding, editing, deleting books, viewing borrow/return management, and Librarian dashboard widgets.

- [ ] **8. Member sees Member-specific navigation and actions**  
  Verify Member users do not see Librarian-only controls and instead see only allowed actions such as searching and borrowing available books.

- [ ] **9. Member cannot access Librarian-only UI pages by direct URL**  
  Paste URLs for add/edit/delete book pages into the browser while logged in as Member and confirm access is blocked.

## Book Management

- [ ] **10. Librarian can open the Add Book form**  
  Verify the form is accessible and contains title, author, genre, ISBN, and total copies fields.

- [ ] **11. Librarian can successfully add a new book with valid data**  
  Submit a valid book and confirm success messaging, correct persistence, and that the new book appears in listings/search.

- [ ] **12. Add Book form validates required fields**  
  Try submitting with missing title, author, genre, ISBN, or total copies and confirm validation messages appear.

- [ ] **13. Add Book form validates field formats and business rules**  
  Check invalid ISBN formats, negative copies, zero copies if disallowed, very long text, and non-numeric copies.

- [ ] **14. Librarian can edit an existing book**  
  Verify existing values load into the form, edits save correctly, and the book detail/list view reflects the changes.

- [ ] **15. Edit Book form shows validation errors for invalid updates**  
  Attempt to save invalid data and confirm changes are rejected with clear UI errors.

- [ ] **16. Librarian can delete a book**  
  Verify delete control exists, asks for confirmation if expected, removes the book from lists, and shows success feedback.

- [ ] **17. Deleting a book handles dependent/borrowed state correctly**  
  If the UI allows deletion only under certain conditions, verify correct blocking or messaging when the book is currently borrowed.

- [ ] **18. Member cannot see Add/Edit/Delete book UI controls**  
  Confirm buttons like Add, Edit, and Delete are hidden for Member users in all relevant screens.

- [ ] **19. Books listing page loads correctly**  
  Verify book cards/table rows display correct fields such as title, author, genre, ISBN, availability, and total copies.

## Search

- [ ] **20. Search by title returns correct results**  
  Search using exact match, partial match, case differences, and no-match values.

- [ ] **21. Search by author returns correct results**  
  Verify author-based search behaves correctly with partial names and multiple matching books.

- [ ] **22. Search by genre returns correct results**  
  Verify genre filtering/search returns the correct subset of books.

- [ ] **23. Search handles empty state correctly**  
  Search for something nonexistent and verify a clean `no results` state appears.

- [ ] **24. Search results update correctly after add/edit/delete actions**  
  After changing book data, confirm the search index/UI reflects the latest state.

## Borrowing and Returning

- [ ] **25. Available book shows a Borrow action for Member users**  
  Verify a Member can see and click Borrow only when the book is available.

- [ ] **26. Member can successfully borrow an available book**  
  Confirm the borrow action succeeds, availability updates, and the book appears in the Member dashboard or borrowed list.

- [ ] **27. Borrowed book due date is shown as 2 weeks from borrow date**  
  Verify the UI displays the borrowed date and due date correctly based on the borrow timestamp.

- [ ] **28. Member cannot borrow the same book multiple times**  
  Attempt to borrow the same title again while already having it borrowed and confirm the action is blocked with an appropriate message.

- [ ] **29. Member cannot borrow a book with no available copies**  
  Verify the Borrow button is disabled or the action fails gracefully with proper feedback.

- [ ] **30. Borrow action updates availability counts correctly**  
  Confirm total available copies decrease appropriately after each successful borrow.

- [ ] **31. Borrow confirmation/error messaging is clear**  
  Validate success toast/banner on borrow and meaningful UI messaging for failure cases.

- [ ] **32. Borrowed book appears on Member dashboard**  
  Verify borrowed items list contains the correct book, borrow date if shown, due date, and current status.

- [ ] **33. Overdue borrowed book is visually indicated for Member**  
  Verify overdue books are clearly marked on the Member dashboard once the due date passes.

- [ ] **34. Librarian can view currently borrowed books or borrow records**  
  Confirm the UI exposes the borrowings necessary to manage returns.

- [ ] **35. Librarian can mark a borrowed book as returned**  
  Verify return action is available to Librarian, succeeds, updates status, and removes overdue/borrowed indicators as expected.

- [ ] **36. Member cannot mark a book as returned if only Librarian is allowed**  
  Verify Members do not see return controls and cannot access the return flow by URL.

- [ ] **37. Returning a book updates book availability correctly**  
  After return, verify available copies increase and the book can be borrowed again.

- [ ] **38. Returned book no longer appears as actively borrowed on Member dashboard**  
  Confirm the Member borrowed-books list updates correctly after return.

## Dashboard

- [ ] **39. Librarian dashboard loads all required summary widgets**  
  Verify it shows total books, total borrowed books, books due today, and members with overdue books.

- [ ] **40. Librarian dashboard total books count is correct**  
  Cross-check against the actual books in the system.

- [ ] **41. Librarian dashboard total borrowed books count is correct**  
  Cross-check against active borrow records.

- [ ] **42. Librarian dashboard books due today count/list is correct**  
  Validate books due on the current date appear correctly and only those due today are counted.

- [ ] **43. Librarian dashboard overdue members list is correct**  
  Verify overdue members appear when applicable and disappear after return.

- [ ] **44. Member dashboard loads borrowed books section correctly**  
  Confirm it lists only that member’s borrowed books and not other users’ records.

- [ ] **45. Member dashboard due dates are correct and readable**  
  Verify date format consistency, timezone/date-boundary correctness, and correct association to each borrowed book.

- [ ] **46. Member dashboard overdue section is correct**  
  Confirm overdue books are separated or highlighted correctly and only appear when truly overdue.

- [ ] **47. Role-specific dashboard separation works correctly**  
  Verify Librarian does not see Member dashboard layout and Member does not see Librarian dashboard layout.

## Session, Errors, and State Integrity

- [ ] **48. Session persistence works correctly after refresh**  
  Refresh the page after login and verify the user stays authenticated if expected.

- [ ] **49. Direct navigation/back button behavior is correct around auth flows**  
  Validate browser back button does not expose stale protected content after logout.

- [ ] **50. UI handles backend/server errors gracefully**  
  Trigger or simulate failures for add/edit/delete/borrow/return/search and verify users see friendly errors instead of broken screens.

- [ ] **51. Form validation messages are readable and placed correctly**  
  Ensure field-level and global errors are understandable and tied to the right input/action.

- [ ] **52. Success messages appear after create/update/delete/borrow/return actions**  
  Confirm the UI gives clear confirmation after successful operations.

- [ ] **53. Duplicate submissions are handled safely**  
  Double-click Add Book, Borrow, or Return and confirm no duplicate records or inconsistent state.

- [ ] **54. Pagination or large list behavior works if present**  
  If the UI paginates books or borrowings, verify navigation, counts, and filters behave correctly across pages.

- [ ] **55. Accessibility/basic usability of key flows**  
  Verify buttons, labels, error messages, and forms are visible and understandable; keyboard navigation and focus states should be reasonable if accessibility is in scope.

- [ ] **56. Cross-role data consistency check**  
  Borrow a book as Member, then log in as Librarian and verify the borrowed count, due-today view, and overdue lists reflect the same reality.

- [ ] **57. State transition end-to-end flow: add -> search -> borrow -> dashboard -> return**  
  Run one complete happy path through the system and confirm all screens stay in sync.

- [ ] **58. State transition negative end-to-end flow**  
  Attempt invalid paths such as Member editing books, duplicate borrow, borrowing unavailable book, or unauthenticated access, and verify all are blocked correctly.

- [ ] **59. Date-sensitive edge case around due date**  
  Validate the 2-week due date rule around month-end, leap year if relevant, timezone boundaries, and `due today` logic.

- [ ] **60. Data integrity after refresh/re-login**  
  After key actions, refresh or log out/log back in and verify persisted state remains correct.

## Suggested Test Case Template

| ID | Flow | Role | Preconditions | Steps | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|---|---|
| TC-001 | Registration succeeds | Member | User is logged out | Open sign-up page, fill valid form, submit | Account created and redirected correctly |  | Not Run |
| TC-002 | Login fails with invalid password | Member/Librarian | Existing user exists | Enter wrong password and submit | Error shown, no session created |  | Not Run |
| TC-003 | Librarian adds a book | Librarian | Logged in as Librarian | Open Add Book form, enter valid data, submit | Book created and appears in listing |  | Not Run |
| TC-004 | Member borrows available book | Member | Logged in as Member, book has available copies | Search/select book, click Borrow | Borrow succeeds, due date shown, copies reduced |  | Not Run |
| TC-005 | Librarian marks book as returned | Librarian | Book is currently borrowed | Open borrow record, click Return | Borrow record closed, copies increased |  | Not Run |
