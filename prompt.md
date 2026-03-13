Instead of just using Open Library, use Google API too.

https://developers.google.com/books/docs/v1/using



Google API has this in their JSON



"maturityRating": "NOT_MATURE",

This should be checked, and logged in the book information in DB.



ALSO! If the book is Rejected, it gets deleted after 48 hours. Make sure that this is displayed to the user, and if they want to fix it, they can



Fix these things



🤖 AI Pre-Screen Reviewed Mar 10 at 15:26 ↻ Re-run LIKELY REJECT — Invalid ISBN and unverified title/author suggest the submission contains false in... ## Book Lookup No public records confirm the existence of "Addison Cooke - Book 1" by Johnathon Stokes. The title and author are not recognized in major bibliographic databases or publisher listings. ## Policy Check Potential violation: The submission may involve false information about the title/author, which is explicitly prohibited. No content details are available to assess other policy areas. ## Condition Assessment Declared condition is "Good." No disclosed issues in submission notes, so compliance with physical standards cannot be confirmed or denied. ## Fraud Signals - Title and author names appear generic or fabricated. - ISBN (1234567890246) is invalid (check digit fails ISBN-13 validation). - Lack of submission notes or additional details raises suspicion. ## Recommendation LIKELY REJECT — Invalid ISBN and unverified title/author suggest the submission contains false information.

Make the AI thing support markdown formatting.  Also, the pill label at the top, the LIKELY REJECT thing should just show the recommendation status (the capital words), not the whole text after --

Make the AI review location nominations as well. Crawl the website if listed, research the location to see if they have programs in place already. Check to see if it is a chain. See if the address given is valid, and there is something there.

On all admin buttons, show conformations in the form of modals, if applicable (don't need them for Review ->, Edit or whatever). On the book page, after it has been approved, remove the Reject button. On the review book page, make the reject button just like the Approve Button (with conformation for both, but for the Reject, have a reason), but not field on the review page, just in modal.

Also, for the navbar, make the user avatar and username clickable with dropdown, and move the Labels, My Finds, Friends, and the Books thing to that, also add My Profile. Separate the Books thing into catalog (public), and my books (per user).

also, fix this

ActionView::Template::Error (undefined method '[]' for nil) Caused by: NoMethodError (undefined method '[]' for nil) Information for: ActionView::Template::Error (undefined method '[]' for nil):      6:   <div class="flex items-center gap-3">      7:     <button onclick="window.location.reload()" class="btn-secondary text-sm py-1.5 px-3">↻ Refresh</button>      8:     <% if @stats[:failed] > 0 %>      9:       <%= button_to "🗑 Clear Failed (#{@stats[:failed]})", clear_failed_admin_jobs_path,     10:           method: :delete,     11:           class: "btn-danger text-sm py-1.5 px-3",     12:           data: { confirm: "Permanently discard all #{@stats[:failed]} failed jobs?" } %>

app/views/admin/jobs/index.html.erb:9 Information for cause: NoMethodError (undefined method '[]' for nil):

app/views/admin/jobs/index.html.erb:9

also, please add a proper, good looking homepage



Put those all into Linear Issues, and assign them all to me, Austin Rice, and assign the appropriate labels