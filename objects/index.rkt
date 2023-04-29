#lang r5rs

(#%require
  "form.rkt"
  "member.rkt"
  "object.rkt"
  "polymorph.rkt"
)

(#%provide
  ;; from "form.rkt"
  form->string
  form::subset?
  form::superset?
  
  ;; from "member.rkt"
  members->form
  members->string

  public
  public-readonly
  public-method
  private
  private-readonly
  private-method

  ;; from "object.rkt"
  object
  object->form
  object->string
  object::subset?
  object::superset?

  ;; from "polymorph.rkt"
  new
  polymorph
)
