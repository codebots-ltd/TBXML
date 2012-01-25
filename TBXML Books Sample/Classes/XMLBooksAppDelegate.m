// ================================================================================================
//  Created by Tom Bradley on 21/10/2009.
//  Version 1.5
//  
//  Copyright 2012 71Squared All rights reserved.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================

#import "XMLBooksAppDelegate.h"
#import "XMLAuthorsViewController.h"
#import "Author.h"
#import "Book.h"

@implementation XMLBooksAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize authors;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	// Grab an XML file from a url and traverse all elements. Output is displayed in the log window.	
	[self loadURL];
	
	// Traverse all elements from an XML string. Output is displayed in the log window.
	[self loadXMLString];
	
	// Traverse all elements from an NSData object. Output is displayed in the log window.
	[self loadXMLData];
	
	// Traverse all elements from an unknown XML document. Output is displayed in the log window.
	[self loadUnknownXML];
	
	// Load the books xml file into a class structure for displaying through tableviews.
	[self loadBooks];
	
    // Load the books xml file and use the block iteration method to query the XML
	[self iterateBooks];
	
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)loadURL {
    
    // Create a success block to be called when the asyn request completes
    TBXMLSuccessBlock successBlock = ^(TBXML *tbxmlDocument) {
        NSLog(@"PROCESSING ASYNC CALLBACK");
        
        // If TBXML found a root node, process element and iterate all children
        if (tbxmlDocument.rootXMLElement)
            [self traverseElement:tbxmlDocument.rootXMLElement];

    };
    
    // Create a failure block that gets called if something goes wrong
    TBXMLFailureBlock failureBlock = ^(TBXML *tbxmlDocument, NSError * error) {
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
    };
    
	// Initialize TBXML with the URL of an XML doc. TBXML asynchronously loads and parses the file.
	tbxml = [[TBXML alloc] initWithURL:[NSURL URLWithString:@"http://www.w3schools.com/XML/note.xml"] 
                               success:successBlock 
                               failure:failureBlock];
}

- (void)loadXMLString {

    // error var
    NSError *error = nil;
    
	// Load and parse an xml string
	tbxml = [[TBXML alloc] initWithXMLString:@"<root><elem1 attribute1=\"elem1-attribute1\"/><elem2 attribute2=\"attribute2\"/></root>" error:&error];

    // if an error occured, log it
    if (error) {
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
        
    } else {

        // If TBXML found a root node, process element and iterate all children
        if (tbxml.rootXMLElement)
            [self traverseElement:tbxml.rootXMLElement];
    }	
}

- (void)loadXMLData {
	// Load and parse an NSData object
	NSString * xmlString = @"<root><elem1 attribute1=\"elem1-attribute1\"/><elem2 attribute2=\"attribute2\"/></root>";
	NSData * xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];

    // error var
    NSError *error = nil;
	tbxml = [[TBXML alloc] initWithXMLData:xmlData error:&error];
    
    // if an error occured, log it    
    if (error) {
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
        
    } else {
	
        // If TBXML found a root node, process element and iterate all children
        if (tbxml.rootXMLElement)
            [self traverseElement:tbxml.rootXMLElement];
    }
}

- (void)iterateBooks {
    
    // error var
    __block NSError *error = nil;
    
	// Load and parse the books.xml file
	tbxml = [TBXML tbxmlWithXMLFile:@"books.xml" error:&error];
    
    // if an error occured, log it    
    if (error) { 
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
        
    } else {
        
        // iterate all child elements of tbxml.rootXMLElement that are named "author"
        [TBXML iterateElementsForQuery:@"author" fromElement:tbxml.rootXMLElement withBlock:^(TBXMLElement *anElement) {

            // get the name of the current element
            NSString * name = [TBXML elementName:anElement error:&error];

            // if an error occured, log it    
            if (error) {
                NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);
            } else {
                // log the element name and "name" attribute
                NSLog(@"Author Name:%@", name);
                NSLog(@"Author Name:%@", [TBXML valueOfAttributeNamed:@"name" forElement:anElement]);
            }
        }];
        
    }
}

- (void)loadBooks {
	// instantiate an array to hold author objects
	authors = [[NSMutableArray alloc] initWithCapacity:10];
	
    // error var
    NSError *error = nil;
    
	// Load and parse the books.xml file
	tbxml = [TBXML tbxmlWithXMLFile:@"books.xml" error:&error];
    
    // if an error occured, log it    
    if (error) { 
        NSLog(@"Error! %@ %@", [error localizedDescription], [error userInfo]);

    } else {

        // Obtain root element
        TBXMLElement * root = tbxml.rootXMLElement;
        
        // if root element is valid
        if (root) {
            // search for the first author element within the root element's children
            TBXMLElement * author = [TBXML childElementNamed:@"author" parentElement:root];
            
            // if an author element was found
            while (author != nil) {
                
                // instantiate an author object
                Author * anAuthor = [[Author alloc] init];
                
                // get the name attribute from the author element
                anAuthor.name = [TBXML valueOfAttributeNamed:@"name" forElement:author];
                
                // search the author's child elements for a book element
                TBXMLElement * book = [TBXML childElementNamed:@"book" parentElement:author];
                
                // if a book element was found
                while (book != nil) {
                    
                    // instantiate a book object
                    Book * aBook = [[Book alloc] init];
                    
                    // extract the title attribute from the book element
                    aBook.title = [TBXML valueOfAttributeNamed:@"title" forElement:book];

                    // extract the title attribute from the book element
                    NSString * price = [TBXML valueOfAttributeNamed:@"price" forElement:book];
                    
                    // if we found a price
                    if (price != nil) {
                        // obtain the price from the book element
                        aBook.price = [NSNumber numberWithFloat:[price floatValue]];
                    }
                    
                    // find the description child element of the book element
                    TBXMLElement * desc = [TBXML childElementNamed:@"description" parentElement:book];
                    
                    // if we found a description
                    if (desc != nil) {
                        // obtain the text from the description element
                        aBook.description = [TBXML textForElement:desc];
                    }
                    
                    // add the book object to the author's books array
                    [anAuthor.books addObject:aBook];
                    
                    // find the next sibling element named "book"
                    book = [TBXML nextSiblingNamed:@"book" searchFromElement:book];
                }
                
                // add our author object to the authors array
                [authors addObject:anAuthor];
                
                // find the next sibling element named "author"
                author = [TBXML nextSiblingNamed:@"author" searchFromElement:author];
            }			
        }
    }
}

- (void)loadUnknownXML {	
    
    // error var
    NSError *error = nil;
    
	// Load and parse the books.xml file
	tbxml = [[TBXML alloc] initWithXMLFile:@"books" fileExtension:@"xml" error:&error];
    
    // if an error occured, log it
    if (error) { 
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
    
    } else {
        // If TBXML found a root node, process element and iterate all children
        if (tbxml.rootXMLElement)
            [self traverseElement:tbxml.rootXMLElement];
    }
}
									  
- (void) traverseElement:(TBXMLElement *)element {
	
	do {
		// Display the name of the element
		NSLog(@"%@",[TBXML elementName:element]);
		
		// Obtain first attribute from element
		TBXMLAttribute * attribute = element->firstAttribute;
		
		// if attribute is valid
		while (attribute) {
			// Display name and value of attribute to the log window
			NSLog(@"%@->%@ = %@",[TBXML elementName:element],[TBXML attributeName:attribute], [TBXML attributeValue:attribute]);
			
			// Obtain the next attribute
			attribute = attribute->next;
		}
		
		// if the element has child elements, process them
		if (element->firstChild) [self traverseElement:element->firstChild];
								  
	// Obtain next sibling element
	} while ((element = element->nextSibling));  
}

@end
