install.packages(c("ellmer","usethis"))
library(ellmer)
library(usethis)
usethis::edit_r_environ()

key <- Sys.getenv("GROQ_API_KEYS")
substr(key,1,10)

#minimal pattern for LLM call
library(ellmer)
chat <- chat_groq(model="llama-3.1-8b-instant", system_prompt="you are a helpful assistant")

# R6 Object. we use the chat method of this object
chat$chat("what is R? explain in one sentence")

# Exercise: One Prompt, three Terms
chat <- chat_groq(model="llama-3.1-8b-instant",system_prompt=paste("you are a concise econometrics tutor",
                                                                    " For every term the user sends, respond exactly 2 lines:",
                                                                    "Line 1: a one-sentence definition.",
                                                                    "Line 2: one concrete empirical example"))
chat$chat("normal distribution")
chat$chat("endogenity")
chat$chat("What is the opposite of endogenity")
chat$chat("bias")
chat$chat("what is the mean of the height of population that you mention before?")


chat <- chat_groq(model="llama-3.1-8b-instant",system_prompt=paste("you are a concise econometrics tutor",
                                                                   " For every term the user sends, respond exactly 1 lines:",
                                                                   "Line 1: a one-sentence definition."),echo= "none")
heterokedascity <- chat$chat("heterokedascity")
cat(heterokedascity)

chat1 <- chat_groq(model="llama-3.1-8b-instant",system_prompt=" Explain like I am a 5 year old")
chat2 <- chat_groq(model="llama-3.1-8b-instant",system_prompt="You are a strict econometrics professor. Be precise and formal")
q <- "What is OLS Regression"
chat1$chat(q)
chat2$chat(q)


# Make Prompt Experiments reuseable

ask <- function(system_message, user_question) {
  chat <- chat_groq(model="llama-3.1-8b-instant",system_prompt = system_message,echo="none")
  return(chat$chat(user_question))}

ask(system_message="You are an expert vietnnamese cook, Answer briefly the question in vietnames", user_question="how to prepare Pho")

?chat_ollama
# LM Studio

# Interactive
chat <- chat_groq(
  model="llama-3.1-8b-instant",
  system_prompt="you are data science assistant"
)
live_console(chat)
library(shinychat)
live_browser(chat)

# Mini Case Study
document <- "~/Documents/uni_UDE/AdvanceR/med_invoice.jpeg" 
chat <-chat_groq(model="meta-llama/llama-4-scout-17b-16e-instruct",
                 system_prompt=paste("you are a careful OCR assistant","Extract the visible document content and return only markdown",
                  "Preserve headings, paragraphs, lists,tables, and signatures",
                  "mark unreadable text as [illegible]"),
                 echo="none",
                 params=params(temperature=0))
markdown_doc <- chat$chat("convert this scanned document into clean Markdown and translate to english",
                          content_image_file(document,resize="high"))
markdown_doc

result <- chat$chat_structured(
  content_image_file(document, resize = "high"),
  type = type_array(
    type_object(
      item_quantity = type_number(),
      item_name     = type_string(),
      item_price    = type_number()
    ) # Closes type_object
  ) # Closes type_array
)
result

library(ellmer)

library(ellmer)

library(ellmer)
library(jsonlite)

# 1. Start Groq telling it to explicitly use a json_object response format
chat <- chat_groq(
  model = "llama-3.3-70b-versatile",
  system_prompt = "You are a precise data extraction assistant. You MUST reply ONLY with a valid JSON object matching the requested schema.",
  api_args = list(response_format = list(type = "json_object")),
  echo = "none"
)

review <- "The app is easy to use and the charts are beautiful, but it crashes whenever I import a large CSV file."

# 2. Provide the JSON schema layout inside the prompt text
prompt <- paste(
  "Analyze this review: '", review, "'\n\n",
  "Return a JSON object matching this exact schema layout:\n",
  "{\n",
  "  \"sentiment\": \"positive\", \"negative\", or \"neutral\",\n",
  "  \"confidence\": 0.95,\n",
  "  \"reason\": \"One short sentence explaining why.\"\n",
  "}"
)

# 3. Call the model and parse the raw JSON string directly into a native R list
raw_response <- chat$chat(prompt)
result <- jsonlite::fromJSON(raw_response)
