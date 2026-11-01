# FQ-5 · Gate 1 · Product: ClaimKit alpha

## The person's problem

Something went wrong: a suitcase did not arrive, a car was hit in a parking lot, or a
bathroom flooded. The person has insurance, but making the claim is the hard part. They do
not know:

- what the insurer needs from them
- by when they have to report it
- which receipts and photos count as evidence
- how to write a letter that the insurer can process without asking them back for more

Many people give up, or they send an incomplete claim and lose weeks going back and forth.
Paid claim agents take a cut. Lawyers are too expensive for a lost suitcase.

## What success looks like

These are the alpha's measures. They mirror ALPHA_DONE in the charter.

- An invited tester completes one claim of each type in Czech and downloads its documents:
  - travel, which covers a delayed flight, lost baggage and medical expenses abroad
  - a motor accident
  - home and property
- A tester with no help finishes a travel baggage claim in under 15 minutes. We time this
  in the alpha sessions.
- Every downloaded letter contains everything the tester entered:
  - insurer
  - policy number
  - incident date and description
  - amount claimed
  - list of evidence
- Testers with no technical background can work out four things without being told:
  - the app gives no legal advice
  - they send the documents themselves
  - their data stays in their browser
  - deadline and legal hints marked "informativní" are not verified
- No claim data ever leaves the tester's device.

## Announcement, as if it shipped

> **ClaimKit alpha: prepare your insurance claim yourself, in 15 minutes.**
>
> Pick what happened: a travel problem, a car accident, or damage at home. ClaimKit asks
> one short group of questions per screen. At the end you download three PDFs:
>
> - a claim letter for your insurer
> - an index of your evidence
> - a summary of the deadlines that apply to you
>
> You check the documents and send them yourself. ClaimKit never contacts your insurer.
>
> Your answers are saved only in your browser, so you can close the tab and continue
> later. You can export a draft to a file, import it on another computer, or delete
> everything with one button. There are no accounts, no tracking and no server holding
> your data.
>
> ClaimKit does not give legal advice. The legal hints it shows are general information
> and are marked as not yet verified by a lawyer.
>
> The alpha is in Czech and English, for Czech insurance. Please test it with an invented
> claim.

## Screens (mockups in `mockups/`)

The mockups are draft sketches made locally with OpenUI. Their wording is placeholder, and
their labels, insurer names and deadlines are illustrative only.

1. `01-start.html`: the start page. It offers a choice of three claim types and states up
   front that the app gives no legal advice and keeps data only in this browser.
2. `02-wizard-step.html`: one wizard step from travel / lost baggage. It shows one
   question group, progress, and an "autosaved" note.
3. `03-review.html`: the review screen before download. It shows:
   - the claim summary with edit links
   - the deadlines, with an "informativní, neověřeno" badge
   - the three documents to be generated
   - the required "I checked this, and I send it myself" checkbox
4. `04-drafts.html`: "My drafts". From here the user can resume or delete a draft, export
   or import JSON, and delete all their data.

The motor accident flow works the same way. It collects the same facts as the European
Accident Statement and prints a summary that maps each answer to the form's sections. It
does not reproduce the form itself.

## What we are deliberately not doing

- **Sending.** No email, data box (datová schránka), or insurer API. The user sends the
  documents.
- **Accounts, payments, analytics, cookies.** None at all. No server stores claim data.
- **Legal advice or a claim assessment.** We do not say "you are entitled to X CZK" or
  "your claim will succeed". Legal references and deadlines appear only as general
  information, marked unverified until a Czech lawyer signs them off.
- **Health and life insurance**, apart from medical expenses abroad under travel
  insurance. That flow asks only for dates, place, amounts and the list of invoices,
  never for a diagnosis or treatment details.
- **Other countries.** The alpha covers Czech insurance only.
- **Reproducing the European Accident Statement form.** We collect the facts and map them
  to the form's sections. The user still fills in the official form at the scene.
- **Insurer logos or branding.** The insurer directory lists names and claims contacts
  only.
- **Real claimant data in the alpha.** Testers use invented claims. The first real claim
  needs the charter's `client-production` tier first.
- **Mobile apps and offline install (PWA).** The alpha is a responsive web page.
- **Automatic data extraction.** No reading of receipts or photos (OCR), and no AI in the
  product. The user types the facts; evidence files are listed in the index by name and
  are not uploaded anywhere.

## Kill check

Should this exist? Yes, if a tester can finish a real-shaped claim faster than they could
by writing a letter themselves, and every document is one they would send. If the alpha
sessions show testers cannot tell that the app gives no legal advice, we stop and redesign
before we add more claim types.
