class <%= class_name %> < MongoModel::<%= "Embedded" if options[:embedded] %>Document
  <%- attributes.each do |a| -%>
  <%= "property :#{a.name}, #{a.type.capitalize}" %>
  <%- end -%>
  <%= "timestamps!" if options[:timestamps] && !options[:embedded] %>
end
