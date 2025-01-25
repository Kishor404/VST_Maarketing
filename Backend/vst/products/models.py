from django.db import models
import os

def product_image_upload_to(instance, filename):
    # Placeholder for initial image upload; the real name will be set in save()
    return f"{filename}"

class Product(models.Model):
    name = models.CharField(max_length=255)
    region = models.CharField(max_length=255)
    details = models.TextField(blank=False, null=False)
    features = models.JSONField(blank=True, null=True)
    image = models.ImageField(upload_to=product_image_upload_to, blank=True, null=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        is_new = self.pk is None  # Check if this is a new object
        super().save(*args, **kwargs)  # Save the object to assign an ID

        if is_new and self.image:  # Rename only if a new object with an image
            ext = self.image.name.split('.')[-1]  # Get file extension
            new_image_name = f"{self.id}.{ext}"  # New file name
            old_image_path = self.image.path
            new_image_path = os.path.join(os.path.dirname(old_image_path), new_image_name)

            # Move the file to the new name
            os.makedirs(os.path.dirname(new_image_path), exist_ok=True)  # Ensure directory exists
            os.rename(old_image_path, new_image_path)

            # Update the database field with the new file name
            self.image.name = new_image_name
            super().save(update_fields=['image'])
