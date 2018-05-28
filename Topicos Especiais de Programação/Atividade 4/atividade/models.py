from django.db import models


# Create your models here.

class User(models.Model):
    name = models.CharField(max_length=255)
    email = models.CharField(max_length=255)

    @property
    def address(self):
        return Address.objects.filter(user=self)

    @property
    def posts(self):
        return Post.objects.filter(user=self)

    def __str__(self):
        return self.name


class Address(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    street = models.CharField(max_length=255)
    suite = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    zipcode = models.CharField(max_length=255)

    class Meta:
        ordering = ('zipcode',)

    def __str__(self):
        return self.zipcode


class Post(models.Model):
    title = models.CharField(max_length=255)
    body = models.CharField(max_length=255)
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        ordering = ('pk',)

    def __str__(self):
        return self.title

    @property
    def comments(self):
        return Comment.objects.filter(post=self)

    @property
    def count_comments(self):
        return Comment.objects.filter(post=self).count()


class Comment(models.Model):
    name = models.CharField(max_length=255)
    email = models.CharField(max_length=255)
    body = models.CharField(max_length=255)
    post = models.ForeignKey(Post, related_name='comment', on_delete=models.CASCADE)
