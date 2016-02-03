require "sinatra"
require "digest"
require "json"

post "/graph" do
  return if params[:token] != ENV["SLACK_TOKEN"]
  p params
  json = params[:text]

  statement = JSON.parse(json)

  file_name = Digest::SHA256.hexdigest(json) + ".pdf"
  pdf_dir = Pathname.new("public")
  pdf_dir.mkpath
  require "conceptql/fake_annotater"
  require "conceptql/annotate_grapher"
  annotated = ConceptQL::FakeAnnotater.new(statement).annotate
  puts annotated
  file_path = pdf_dir + file_name
  ConceptQL::AnnotateGrapher.new.graph_it(annotated, file_path)

  respond(ENV['HOST_URL'] + file_name)

end

def respond(message)
  puts message
  content_type :json
  { text: message }.to_json
end
