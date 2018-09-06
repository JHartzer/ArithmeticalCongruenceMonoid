# Class: ArithmeticCongruenceMonoid
#
# Author: Jacob Hartzer
# Last Edited 3/3/2016
#
# This is a python class based around the factorization of Arithmetical Congruence 
# 	Monoids (ACMs). Most of the operations are primitive, but nonetheless very useful
#	in analyzing patterns in ACMs. 
#
#####################################################################################
#
#	Usage
# 
#	load('/path/to/file/ArithmeticalCongruenceMonoid.sage)
#
#	Hilbert = ArithmeticCongruenceMonoid([1,4])
#	Hilbert.function()
#
#####################################################################################


class ArithmeticCongruenceMonoid:
	
	
	def __init__(self, elements):
		if (elements[0]^2)%elements[1]!=elements[0]:
			print 'error: a must be equivalent to a^2 mod b'
			return null
		self.elements = elements
		self.ACMdict = {1:[[]]}
		self.IrreduciblesDict = {}
		
	
	
	def ArithmeticFactorizations(self, num):
		import itertools
		
		if num in self.ACMdict: 
			return self.ACMdict[num]
		#Builds lists of possible factors by all possible combinations of each prime factor
		Factors = factor(num)
		A = [1]
		for i in range(len(Factors)):
			B = []
			for j in range(1,Factors[i][1]+1):
				for k in A:
					B.append(k*(Factors[i][0])^j)
			A = A + B
		#removes all numbers not in the monoid
		Arithmetic_Factors = [i for i in A if (i%self.elements[1] == self.elements[0] or i == 1)]
		#runs the recursive program to find list of factorizations 
		return  self.ACMfactor(num, Arithmetic_Factors)

		
	def ACMfactor(self,num,factors):
		# Magical recursive program that builds lists of factorizations by tree. It
		# builds from bottom up, adding factors at each branch. Just trust that it works. I checked
		if num in self.ACMdict: 
			return self.ACMdict[num]
		else:
			self.ACMdict[num] = []
			for f in factors[1:]:
				if num/f in factors and ((num/f == 1 and len(self.ACMdict[num]) == 0) or len(self.ACMfactor(f,factors)[0]) == 1):
					smallerfactors = []
					smallerfactors = deepcopy(self.ACMfactor(num/f,factors))
					for k in range(len(smallerfactors)):
						if smallerfactors[k] == [] or f >= smallerfactors[k][-1]:
							smallerfactors[k].append(f)
							self.ACMdict[num] = self.ACMdict[num] + [smallerfactors[k]]
			return self.ACMdict[num]
		
		
	def ArithmeticFactorizationsUpToElement(self, nmax):
		# Finds all arithmetic factorizations up to a certain element. Useful to run before long calculations
		for i in range(self.elements[0],nmax+1,self.elements[1]):
			self.ArithmeticFactorizations(i)
		return "done"
		

	def LongestFactorizationsInRange(self, nmax):
		# returns indices and length of element with longest factorization
		self.ArithmeticFactorizationsUpToElement(nmax)
		index = []
		max_length = 0
		for i in range(self.elements[0],nmax+1,self.elements[1]):
			if len(self.ArithmeticFactorizations(i)) > max_length:
				max_length = len(self.ArithmeticFactorizations(i))
				index = [i]
			elif len(self.ArithmeticFactorizations(i)) == max_length:
				index.append(i)
		return index, max_length
		
		
	def NumberOfFactorizations(self,num):
		# returns the number of factorizations of an element
		return len(self.ArithmeticFactorizations(num))
		
		
	def PlotNumberOfFactorizationsToElement(self,nmax):
		# plots number of factorizations up to a given element
		plot_list=[]
		for i in range(self.elements[0]+self.elements[1],nmax+1,self.elements[1]):
			plot_list.append([i,self.NumberOfFactorizations(i)])
		return list_plot(plot_list)
		
		
	def MaxFactorizationLength(self,num):
		# finds the max factorization length of a given element
		max_length = 1
		for i in range(self.NumberOfFactorizations(num)):
			if len(self.ArithmeticFactorizations(num)[i]) > max_length:
				max_length = len(self.ArithmeticFactorizations(num)[i])
		return max_length
	
	
	def MinFactorizationLength(self,num):
		# finds the min factorization length of a given element
		min = len(self.ArithmeticFactorizations(num)[0])
		for i in range(self.NumberOfFactorizations(num)):
			if len(self.ArithmeticFactorizations(num)[i]) < min:
				min = len(self.ArithmeticFactorizations(num)[i])
		return min
	
	
	def PlotMaxFactorizationLengthToElement(self,nmax):
		# plots max factorization length up to a given element
		plot_list=[]
		for i in range(self.elements[0]+self.elements[1],nmax+1,self.elements[1]):
			plot_list.append([i,self.MaxFactorizationLength(i)])
		return list_plot(plot_list)
	
	
	def PlotMinFactorizationLengthToElement(self,nmax):
		# plots min factorization length up to a given element
		plot_list=[]
		for i in range(self.elements[0]+self.elements[1],nmax+1,self.elements[1]):
			plot_list.append([i,self.MinFactorizationLength(i)])
		return list_plot(plot_list)
	
	
	def Elasticity(self,num):
		# finds elasticity of an element: max factorization length / min...
		if num == 1:
			return 1
		return float(self.MaxFactorizationLength(num))/float(self.MinFactorizationLength(num))
	
	
	def MaxElasticityToElement(self,nmax):
		# Fins max elasticity to given element.
		max_elasticity = 0
		for i in range(self.elements[0]+self.elements[1],nmax+1,self.elements[1]):
			if self.Elasticity(i) >= max_elasticity:
				max_elasticity = self.Elasticity(i)
		return max_elasticity

		
	def PlotElasticitiesToElement(self,nmax):
		# plots elasticities to a given element 
		plot_list=[]
		for i in range(self.elements[0]+self.elements[1],nmax+1,self.elements[1]):
			plot_list.append([i,self.Elasticity(i)])
		p = list_plot(plot_list,figsize=(10,4),size = 5,title = 'Elasticities of M_4,6')
		return p
	
	
	def IsIrreducible(self,num):
		# checks if an element is irreducible. 
		if self.MaxFactorizationLength(num) == 1:
			self.IrreduciblesDict[num] = 1
			return "true"
		else:
			return "false"
			
	
	def PlotIrreduciblesToElement(self,nmax):
		# plots irreducibles to a given element (irreducible = 1)
		self.IrreduciblesUpToElement(nmax)
		p = list_plot(self.IrreduciblesDict,figsize=(10,4),size = 50,title = 'Irreducibles of M_4,6',ymin = -0.5,ymax = 1.5)
		return p
		
	
	
	def IrreduciblesUpToElement(self,nmax):
		# creates a dict of the irreducibles up to a given element 
		start = self.elements[0]
		if self.elements[0] == 1:
			start = start + self.elements[1]		
		
		for i in range(start,nmax,self.elements[1]):
			self.IrreduciblesDict[i] = 1 #pre allocates dictionary memory

		for i in range(start,nmax,self.elements[1]):
			for j in range(i,nmax/i+1,self.elements[1]):#for each product of two elements, sets dict(product) = 0
				self.IrreduciblesDict[i*j] = 0			# essentially a Sieve of Eratosthenes for ACMs
					
	
	def FindMaxDeltaSet_Irreducibles(self,nmax):
		# Finds the largest distance between two irreducible elements 
		self.IrreduciblesUpToElement(nmax)
		max_delta = 1
		start = self.elements[0]
		if start == 1:
			start = start + self.elements[1]
		hold = start
		for i in range(start,nmax,self.elements[1]):
			if self.IrreduciblesDict[i] == 1:
				if (i-hold)>max_delta:
					max_delta = i-hold
					print max_delta,i,factor(i)
				hold = i
				
				
	def FindMaxDeltaSet_Reducibles(self,nmax):
		# Finds the largest distance between two reducible elements 
		self.IrreduciblesUpToElement(nmax)
		max_delta = 1
		start = self.elements[0]
		if start == 1:
			start = start + self.elements[1]
		hold = start 
		for i in range(start,nmax,self.elements[1]):
			if self.IrreduciblesDict[i] == 0:
				if (i-hold)>max_delta:
					max_delta = i-hold
					print max_delta,i,factor(i)
				hold = i
	
	def PlotDeltaSet_Reducibles(self,nmax):
		# plots the delta set of reducible elements to a given element.
		# delta set is the distance between consecutive reducibles
		self.IrreduciblesUpToElement(nmax)
		hold = self.elements[0]
		delta_list = []
		for i in range(self.elements[0]+self.elements[1],nmax,self.elements[1]):
			if self.IrreduciblesDict[i] == 0:
				delta_list = delta_list + [i-hold]
				hold = i
		return list_plot(delta_list)
		
	
	def PlotDeltaSet_Irreducibles(self,nmax):
		# plots the delta set of irreducible elements to a given element.
		# delta set is the distance between consecutive irreducibles
		self.IrreduciblesUpToElement(nmax)
		hold = self.elements[0]
		delta_list = []
		for i in range(self.elements[0]+self.elements[1],nmax,self.elements[1]):
			if self.IrreduciblesDict[i] == 1:
				delta_list = delta_list + [i-hold]
				hold = i
		return list_plot(delta_list)
		
	def PlotVariableDeltaSet_Reducibles(self,nmax,start,period):
		# if you want to change the period in which the program looks for irreducibles
		# this will do that for you. 
		self.IrreduciblesUpToElement(nmax)
		hold = self.elements[0] + start*self.elements[1]
		delta_list = []
		for i in range(self.elements[0] + start*self.elements[1], nmax, period*self.elements[1]):
			if self.IrreduciblesDict[i] == 0:
				delta_list = delta_list + [(i-hold)/period]
				hold = i
		return list_plot(delta_list)
		
	def Percent_Irreducible(self,nmax):
		# returns the percent of elements that irreducible to a given element 
		self.IrreduciblesUpToElement(nmax)
		return float(sum(self.IrreduciblesDict.values())/len(self.IrreduciblesDict))
		
		
