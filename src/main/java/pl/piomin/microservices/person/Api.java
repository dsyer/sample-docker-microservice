package pl.piomin.microservices.person;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/persons")
public class Api {

	protected Logger logger = LoggerFactory.getLogger(Api.class.getName());
	
	private List<Person> persons;
	
	public Api() {
		persons = new ArrayList<>();
		persons.add(new Person(1, "Jan", "Kowalski", 22));
		persons.add(new Person(1, "Adam", "Malinowski", 33));
		persons.add(new Person(1, "Tomasz", "Janowski", 25));
		persons.add(new Person(1, "Alina", "Iksińska", 54));
	}

	@GetMapping
	public List<Person> findAll() {
		logger.info("Api.findAll()");
		return persons;
	}
	
	@GetMapping("/{id}")
	public Person findById(@PathVariable("id") Integer id) {
		logger.info(String.format("Api.findById(%d)", id));
		return persons.stream().filter(p -> (p.getId().intValue() == id)).findAny().get();
	}
	
}
