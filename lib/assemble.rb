doc = []
filename = Dir.pwd.split("/").last
doc << "/*#{Time.now.to_i}*/\n"

Dir.entries("exec").each do |file|
  unless file == "." || file == ".." || file.split("")[0] == "."
    File.read("./exec/#{file}").split("\n").each do |line|
      doc << line
    end
  end
end

File.write("#{filename}.pde", doc.join("\n"))
