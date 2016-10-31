//
//  Product+CoreDataProperties.h
//  
//
//  Created by JAY on 8/23/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *purchased;

@end

NS_ASSUME_NONNULL_END
