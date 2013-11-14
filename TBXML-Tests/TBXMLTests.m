//
//  TBXMLTests.m
//  TBXMLTests
//
//  Created by Tom Bradley on 29/01/2012.
//  Copyright (c) 2012 71 Squared. All rights reserved.
//

#import "TBXMLTests.h"
#import "TBXML.h"

@implementation TBXMLTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testLoadXMLResourceFailure
{   
    NSError *error;
    [TBXML newTBXMLWithXMLFile:@"some-file-that-doesnt-exist.xml" error:&error];
    
    STAssertTrue([error code] == D_TBXML_FILE_NOT_FOUND_IN_BUNDLE, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)testLoadXMLResource
{   
    NSError *error;
    [TBXML newTBXMLWithXMLFile:@"books.xml" error:&error];
    
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
}


/*
 
 <?xml version="1.0"?>
 <authors>
 
    <author name="AUTHOR NAME">
        <book title="TITLE" price="1.10">
 
            <description>
                Descr A
            </description>
        </book>
 
        <book title="TITLE B" price="2.20">
            <description>
                    Descr B
            </description>
        </book>

    </author>

</authors>

 */

//NSMutableArray *records;

- (void)testSimpleQuery_main
{
    NSError *error;
    TBXML *tbxml;

    
    //records = [NSMutableArray array];
    
    tbxml = [TBXML newTBXMLWithXMLFile:@"books.xml" error:&error];

    if (tbxml.rootXMLElement) {
        [self testSimpleQuery_traverseElement:tbxml.rootXMLElement];
    } else {
       NSLog(@"ERROR");
        STAssertTrue([error code] == D_TBXML_DATA_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    }

}

- (void) testSimpleQuery_traverseElement:(TBXMLElement *)element {
    
    do {
        
        //
        // Display the name of the element
        //

        /*NSLog(@"\n");
        NSLog(@"-----------------------------------------------------");
        NSLog(@"- TBXML elementName = %@", [TBXML elementName:element]);*/

    
        //
        // -- match /authors/author
        //
        
        if ([[TBXML elementName:element] isEqualToString:@"author"]) {

            // -- get //author/@name
            TBXMLAttribute *attribute = element->firstAttribute;
            NSString *myAuthor = [TBXML attributeValue:attribute];

            NSLog(@"-----------------------------------------------------");
            NSLog(@"-+ //author/@name = \"%@\"", myAuthor);
            
        }

        //
        // -- match /authors/author/book
        //
        
        if ([[TBXML elementName:element] isEqualToString:@"book"]) {
            
            // -- ok, we got book
          
            //  <book title="TITLE" price="1.10">

            TBXMLAttribute *attribute = element->firstAttribute;
            
            NSString *myTitle = [TBXML attributeValue:attribute];  // note: we assume that the title attribut comes first
            
            attribute = attribute->next;  // point to next attribute (price here)
            
            NSString *myPrice = [TBXML attributeValue:attribute];
            
            NSLog(@" +- //author/book/@title: \"%@\"", myTitle);
            NSLog(@" +- //author/book/@price: \"%@\"", myPrice);
            
        }
        
        if ([[TBXML elementName:element] isEqualToString:@"description"]) {
            // -- ok, we got description
            //  <description>Bla bla bla...</decriptiopn>
            NSString * description = [TBXML textForElement:element];
            NSLog(@"  \\- //author/book/description: \"%@\"", description);
        }
        
    
    
        //
        // -- display all XML ATTRIBUTES if any
        // see: http://www.tbxml.co.uk/TBXML/Guides_-_Traversing_Unknown_elements___attributes.html

        // Obtain first attribute from element
        
        /*
         TBXMLAttribute *attribute = element->firstAttribute;

        bool FLAG_thereAreAttributes = NO;
        
        while (attribute) {

            // -- attribute is valid
            FLAG_thereAreAttributes = YES;

            // Display name and value of attribute to the log window
            NSLog(@" -- XML-ATTRIBUT: //%@/@%@ = \"%@\"",
                  [TBXML elementName:element],
                  [TBXML attributeName:attribute],
                  [TBXML attributeValue:attribute]);
            
            // Obtain the next attribute
            attribute = attribute->next;
        }

        if (FLAG_thereAreAttributes == NO ) {
            NSLog(@" -- XML-ATTRIBUT: (no attrubutes for this element)");
        }
        */

        
        if (element->firstChild) {
            // do recursion
            [self testSimpleQuery_traverseElement:element->firstChild];
        }

        
    } while ((element = element->nextSibling));
}

- (void)testDataIsNil
{   
    NSData *data = nil;
    
    NSError *error;
    [TBXML newTBXMLWithXMLData:data error:&error];
    
    STAssertTrue([error code] == D_TBXML_DATA_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)testDecodeError
{   
    NSString *string = @"asdfaf uhaluhlasdh sf a";
    
    NSError *error;
    [TBXML newTBXMLWithXMLString:string error:&error];
    
    STAssertTrue([error code] == D_TBXML_DECODE_FAILURE, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)testDecodeError2
{   
    NSString *string = @"<?xml version=\"1.0\"?><sdf";
    
    NSError *error;
    [TBXML newTBXMLWithXMLString:string error:&error];
    
    STAssertTrue([error code] == D_TBXML_DECODE_FAILURE, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)testElementIsNil
{   
    TBXMLElement * tbxmlElement = nil;
    
    NSError *error;
    NSString * name = [TBXML elementName:tbxmlElement error:&error];
    
    STAssertTrue([error code] == D_TBXML_ELEMENT_IS_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    STAssertTrue([name isEqualToString:@""], @"Returned string is not empty");
}

- (void)testNameIsNil
{   
    NSString *string = @"<?xml version=\"1.0\"?><>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML elementName:tbxml.rootXMLElement error:&error];
    
    STAssertTrue([error code] == D_TBXML_ELEMENT_NAME_IS_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);

}

- (void)testElementNotFound
{   
    NSString *string = @"<?xml version=\"1.0\"?><root></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML childElementNamed:@"anElement" parentElement:tbxml.rootXMLElement error:&error];
    
    STAssertTrue([error code] == D_TBXML_ELEMENT_NOT_FOUND, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
}

- (void)testSiblingElementNotFound
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child /><child2 /></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML nextSiblingNamed:@"child" searchFromElement:element error:&error];
    STAssertTrue([error code] == D_TBXML_ELEMENT_NOT_FOUND, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);    
}

- (void)testAttributeNotFound
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child attrib=\"\"/></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML valueOfAttributeNamed:@"someOtherAttrib" forElement:element error:&error];
    STAssertTrue([error code] == D_TBXML_ATTRIBUTE_NOT_FOUND, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);    
}

- (void)testAttributeNameIsNil
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child attrib=\"\"/></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML valueOfAttributeNamed:nil forElement:element error:&error];
    STAssertTrue([error code] == D_TBXML_ATTRIBUTE_NAME_IS_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);    
}

- (void)testTextIsNil
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child></child></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    [TBXML textForElement:element error:&error];
    STAssertTrue([error code] == D_TBXML_ELEMENT_TEXT_IS_NIL, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);    
}

- (void)testSiblingElement
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child /><child2 /><child /></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * childElement = [TBXML nextSiblingNamed:@"child" searchFromElement:element error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    NSString * name = [TBXML elementName:childElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    STAssertTrue([name isEqualToString:@"child"], @"Incorrect Element Returned %@", name);
}

- (void)testElementText
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child>Element Text</child></root>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    
    NSString * text = [TBXML textForElement:element error:&error];
    STAssertTrue([text isEqualToString:@"Element Text"], @"Incorrect Element Text %@", text);
}

- (void)testNoErrorVars
{   
    NSString *string = @"<?xml version=\"1.0\"?><root><child>Element Text</child></root>";
    
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:nil];
    STAssertTrue(tbxml.rootXMLElement != nil, @"Root element is nil");
    
    TBXMLElement * element = [TBXML childElementNamed:@"child" parentElement:tbxml.rootXMLElement];
    STAssertTrue(tbxml.rootXMLElement != nil, @"Element is nil");
    
    NSString * text = [TBXML textForElement:element];
    STAssertTrue([text isEqualToString:@"Element Text"], @"Incorrect Element Text %@", text);
}

- (void)testRootNodeAttributeEmpty
{   
    NSString *string = @"<?xml version=\"1.0\"?><RESPONSE MSG=\"\"/>";
    
    NSError *error;
    TBXML * tbxml = [TBXML newTBXMLWithXMLString:string error:nil];
    STAssertTrue(tbxml.rootXMLElement != nil, @"Root element is nil");
    
    NSString * value = [TBXML valueOfAttributeNamed:@"MSG" forElement:tbxml.rootXMLElement error:&error];
    STAssertNil(error, @"Incorrect Error Returned %@ %@", [error localizedDescription], [error userInfo]);
    STAssertTrue([value isEqualToString:@""], @"Returned string is not empty");
}

- (void)testDeprecated_tbxmlWithXMLData
{    
    NSString *string = @"abcdefg";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    TBXML *tbxml = [TBXML newTBXMLWithXMLData:data];
    STAssertTrue(tbxml.rootXMLElement == nil, @"Should have failed to parse");
    
    string = @"<?xml version=\"1.0\"?><root><child>Element Text</child></root>";
    data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    tbxml = [TBXML newTBXMLWithXMLData:data];
    STAssertTrue(tbxml.rootXMLElement != nil, @"Should have parsed successfully");

#pragma clang diagnostic pop    

}

@end




































