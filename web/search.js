// instantiate the bloodhound suggestion engine
var numbers = new Bloodhound({
datumTokenizer: Bloodhound.tokenizers.whitespace,
queryTokenizer: Bloodhound.tokenizers.whitespace,
//local:  ["(A)labama","Alaska","Arizona","Arkansas","Arkansas2","Barkansas"]
remote: 'example_collection.json'
});

// initialize the bloodhound suggestion engine
numbers.initialize();

$('#spotlight').typeahead(
{
items: 4,
source:numbers.ttAdapter()  
});