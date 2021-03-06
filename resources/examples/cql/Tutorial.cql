/**
 * This CQL tutorial is a literate CQL file: by running it and then selecting 'emit HTML' 
 * from the CQL menu, the HTML CQL tutorial posted on categorical.info/tutorial.html is obtained.
 */

//HTML output is indicated by html { (* " <html code> " *) }.  
//Markdown (a less verbose way to write HTML) is indicated by
//md { (* " markdown code " *) }.  
//The javascript import provides sorting capability for HTML tables.

html { (* "
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> 
 <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">
 
	<head>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
		<title>CQL Tutorial</title>
		<link rel=\"stylesheet\" type=\"text/css\" href=\"https://categoricaldata.net/css/nstyle.css\" />
		<script src=\"https://categoricaldata.net/js/simple.js\"></script>
	</head>
	<body>
		<h1>CQL Tutorial</h1>
		
			<p> This online CQL tutorial is built-in to the IDE as the Tutorial example.
			    Readers are encouraged to use the IDE while reading the tutorial.
			</p>
			
			<p> Jump to section: <a href=\"#typesides\">Typesides</a>, 
				<a href=\"#schemas\">Schemas</a>, <a href=\"#instances\">Instances</a>, 
				<a href=\"#mappings\">Mappings</a>, 
				<a href=\"#fdm\">Delta and Sigma</a>, 
				<a href=\"#uberflowers\">Uber-flowers</a>,
				<a href=\"#conclusion\">Conclusion</a>.  
			</p>	  
	
		<hr/> <div id=\"typesides\">
		<h2>Typesides</h2>
			<p>Every CQL file begins with a <b>typeside</b>.  
				The typeside for this tutorial contains two <b>java_types</b>: <i>String</i>, 
				which is bound to <i>java.lang.String</i>;
				and <i>Integer</i>, which is bound to <i>java.lang.Integer</i>.  The
				<b>java_constants</b> section defines, for each java_type, javascript code that
				creates a value of that type from a string.  For example, when the string
				100 is encountered in an CQL program and needs to be interpreted as an
				<i>Integer</i>, CQL will execute the <i>parseInt</i> function on the
				string 100, yielding a <i>java.lang.Integer</i>.  Similarly, the 
				<b>java_functions</b> section defines the <i>plus</i> function. 	
			</p></div>" *) }			


typeside Ty = literal { 
	java_types
		String = "java.lang.String"
		Integer = "java.lang.Integer"
	java_constants
		String = "return input[0]"
		Integer = "return java.lang.Integer.parseInt(input[0])"
	java_functions
		plus : Integer,Integer -> Integer = "return (input[0] + input[1]).intValue()"
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/>
	<div id=\"schemas\">
	<h2>Schemas</h2>

		<p>A <b>schema</b> on a typeside <i>Ty</i> contains a set of <b>entities</b>, a set
			of <b>attributes</b> taking entities to types, a set of <b>foreign_keys</b>
			taking entities to entities, a set of <b>path_equations</b> between paths of foreign_keys,
			and a set of <b>observation_equations</b> between attributes and foreign_keys. 
		</p>
		<p> In the following schema, the entities are <i>Employee</i>s and <i>Department</i>.
			The <i>manager</i> foreign_key takes every <i>Employee</i> to their manager, and similarly
			for <i>worksIn</i> and <i>secretary</i>.  The path_equations state that every 
			<i>Employee</i> <i>e</i>'s <i>manager</i> 
			<i>worksIn</i> the <i>Department</i> which <i>e</i> works in, and that every
			<i>Department</i> <i>d</i>'s <i>secretary</i>
			<i>worksIn</i> <i>d</i>.
		</p>   	
		<p>The <i>name</i> attribute takes every <i>Department</i>
			to its name and similarly for <i>first, last, age, cummulative_age</i>.  
			The observation_equations state that every <i>Employee</i> <i>e</i>'s 
			<i>commulative_age</i> is the sum of <i>e</i>'s <i>age</i> and <i>e</i>'s
			<i>manager</i>'s <i>age</i>.
		</p>	</div>" *) }


schema S = literal : Ty {
	entities
		Employee 
		Department
	foreign_keys
		manager   : Employee -> Employee
		worksIn   : Employee -> Department
		secretary : Department -> Employee
	path_equations 
		Employee.manager.worksIn = Employee.worksIn
  		Department.secretary.worksIn = Department
  	attributes
  		first last	: Employee -> String
     	age			: Employee -> Integer
     	cummulative_age: Employee -> Integer
     	name 		: Department -> String
     observation_equations
     	forall e. cummulative_age(e) = plus(age(e), age(manager(e)))
     	options
     	program_allow_nontermination_unsafe=true
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/> <div id=\"instances\">
	<h2>Instances</h2>

		<p>An <b>instance</b> on a schema <i>S</i> contains a set of <b>generators</b>
			and a set of variable-free <b>equations</b> between those generators. 
			In this example, there are three generating <i>Employee</i>s: <i>a,b,c</i>, 
			and two generating <i>Department</i>s: <i>m,s</i>.  The <b>equations</b> specify,
			for example, that the <i>name</i> of <i>m</i> is <i>Math</i>.  The IDE
			shows the tables generated by this instance.
		</p>	
		<p>Note that the IDs in the
			tables do not directly correspond to the generators: CQL chooses 
			IDs non-deterministically (e.g. <i>c</i> does not appear in the instance,
			but <i>b.manager</i> does).  Note also that the tables contain nulls: 
			<i>a.last</i>, for example.  Finally, note that
			the <i>cummulative_age</i> attribute is automatically populated in the tables.
		</p>	
		<p>Tables can be sorted by clicking on their column headers.</p>
		</div>  " *) }

//Readers are advised that it is easy to create infinite instances on this schema unless
//care is taken to assign every employee a manager.  Simply adding a new employee d,
//for example, forces nulls d.manager, d.manager.manager, etc, to exist, creating an
//infinite instance.  One easy way around this problem is to add the path_equation
//manager.manager=manager to S.		
instance I = literal : S {
	generators 
		a b c : Employee
		m s : Department
	equations 
		first(a) = Al
		first(b) = Bob  last(b) = Bo
		first(c) = Carl 
		name(m)  = Math name(s) = CS
		age(a) = age(c) 
		manager(a) = a manager(b) = c manager(c) = c
		worksIn(a) = m worksIn(b) = s worksIn(c) = s
		secretary(s) = c secretary(m) = a 
		secretary(worksIn(a)) = manager(a)
		worksIn(a) = worksIn(manager(a))
		age(a) = "1" 
		age(b) = "5"
	options
		prover_simplify_max = 64	
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/> <div id=\"mappings\">
	<h2>Mappings</h2>

	<p>An <b>mapping</b> from schema <i>C</i> to schema <i>D</i> takes each entity in <i>C</i>
		to an entity <i>D</i>, each foreign_key in <i>C</i> to a path of foreign_keys in <i>D</i>,
		and each attribute in <i>C</i> to a lambda expression in <i>D</i> (which may be abbreviated as a path).  In this example, the 
		two entities <i>N1,N2</i> are taken to <i>N</i>, the foreign_key <i>f</i> is taken to the 
		zero-length path on <i>N</i>, and the attribute <i>age</i> is taken to <i>age</i>.  We also
		define an instance on <i>D</i> which will be used later.
	</p>	"  *) }	

schema C = literal : Ty {
 	entities 
		N1 N2
	foreign_keys
		f : N1 -> N2	
 	attributes
		name : N1 -> String
		salary : N1 -> Integer
		age : N2 -> Integer
}

schema D = literal : Ty {
 	entities 
		N
 	attributes
		name : N -> String
		salary : N -> Integer
		age : N -> Integer
}

mapping F = literal : C -> D {
 	entity 
		N1 -> N
	foreign_keys
		f -> identity
	attributes	
		name -> name //shorter, path-based notation
		salary -> lambda x. salary(x)

	entity
		N2 -> N
 	attributes
		age -> lambda x. age(x) //plus(1,age(x)) interesting to try this - sigma no longer inverse to delta, results in non-trivial type algebra
} 


html { (* " <p>  We also define an instance on <i>D</i> which will be used later. </p> </div> " *) }	

//multi_equations is a convenient shorthand to write lots of equations at once
instance J = literal : D {
	generators 
		one two three : N
	multi_equations
		name -> {one Alice, two Bob, three Sue}
		salary -> {one 100, two 250, three 300}
		age -> {one 20, two 20, three 30}	
}  

/////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/> <div id=\"fdm\" >
	<h2>Delta and Sigma</h2>

	<p>Given a mapping <i>F</i> from schema <i>C</i> to schema <i>D</i>, the <b>delta</b>
		operation converts instances on <i>D</i> to instances on <i>C</i>.  It can be thought
		of as projection:
	</p>	" *) }	

instance deltaFJ = delta F J

html { (* " 
	<p>Given a mapping <i>F</i> from schema <i>C</i> to schema <i>D</i>, the <b>sigma</b>
		operation converts instances on <i>C</i> to instances on <i>D</i>.  It can be thought
		of as union, followed by merge.  In this example, sigma undoes delta:
	</p>	</div>" *) }

instance sigmaFdeltaFJ = sigma F deltaFJ


/////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/> <div id=\"uberflowers\">
	<h2>Uber-flowers (From-Where) queries</h2>

	<p> In addition to mappings, so-called uber-flower <b>queries</b> can be used to define
		relationships between schemas and to migrate data from one schema to another.  Such
		queries can be <b>evaluated</b>, providing a similar semantics to SQL.  However, 
		unlike SQL, CQL guarantees, at compile time, that queries can only result in instances
		which obey their data integrity constraints.
	</p>
	<p> A query from schema <i>C</i> to schema <i>D</i> specifies, for each entity <i>d</i>
		 in <i>D</i>, a from-where-return statement that defines how <i>d</i> is to be
		populated.  In addition, a query specifies how the foreign keys in <i>D</i> must be 
		populated.  Here is a query corresponding to the previous section's delta; it does
		not require any where clauses.  The block corresponding to foreign key <i>f</i>
		says that for each <i>x</i> inserted into <i>N1</i>, the <i>y</i> to which <i>x</i>
		should be sent to by <i>f</i> is <i>x</i>.  In general, the foreign_keys
		part of a query is the most difficult part to write and should be attempted only
		after writing the entities part.		
	</p>" *) }	
 
query deltaFAsQuery = literal : D -> C {
	
	entity	N1 -> {from x:N attributes name -> name(x) salary -> salary(x) foreign_keys f -> {y -> x}}
	entity	N2 -> {from y:N attributes age -> age(y)}	
}

instance deltaFJ_prime = eval deltaFAsQuery J

html { (* " <br/>Here is a query corresponding to the previous section's sigma: </div>" *) }	

//In general, it is not possible to use eval to do a sigma - the
//dual of eval, "coeval", must be used instead.  A good illustration of this is to
//change the mapping F to taking age to age + 1 and similarly for the uber flowers.  In this case, 
//sigmaFdeltaFJ_prime is not the same as sigmaFdeltaFJ.  The former does what
//is natural, and the latter contains labeled nulls and has a non-trivial type algebra.
query sigmaFAsQuery = literal : C -> D {
	entity
		N -> {from n1:N1 attributes name -> name(n1) salary -> salary(n1) age -> age(f(n1))}
}

instance sigmaFdeltaFJ_prime = eval sigmaFAsQuery deltaFJ_prime

//////////////////////////////////////////////////////////////////////////////////////////////////////

html { (* " <hr/> <div id=\"conclusion\">
	<h2>Conclusion</h2>

	<p> This tutorial has barely scratched the surface of CQL's capabilities.  These capabilities
		are described in the other examples built-in to the CQL tool, as well as in the examples
		section of <a href=\"http://categorical.info\">CI's website</a>.  
		In addition, CQL comes with a 
		<a href=\"http://categoricaldata.net/help/index.html\">comprehensive manual</a>
		specifying all available operations.  
	</p>
	<br />
</div></body></html>" *) }	

//it is possible to import mathjax to render math
//		<script type=\"text/javascript\" async src=\"https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML\"></script>

