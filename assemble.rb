doc = []
doc << "/*#{Time.now.to_i}*/\n"

manifest = File.read('manifest.js').split("\n").map do |entry|
  lines = File.read(entry.gsub("//","./exec/")).split("\n")
  lines.each do |line|
    doc << line
  end
end

filename = Dir.pwd.split("/").last
File.write("#{filename}.pde", doc.join("\n"))